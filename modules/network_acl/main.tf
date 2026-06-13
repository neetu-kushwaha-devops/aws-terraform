resource "aws_network_acl" "this" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_network_acl_rule" "this" {
  for_each = { for idx, rule in var.entries : "${lookup(rule, "egress", "false") == "true" ? "egress" : "ingress"}-${rule.rule_number}" => rule }

  network_acl_id  = aws_network_acl.this.id
  rule_number     = tonumber(each.value.rule_number)
  egress          = lookup(each.value, "egress", "false") == "true"
  protocol        = lookup(each.value, "protocol", "-1")
  rule_action     = lookup(each.value, "rule_action", "allow")
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = lookup(each.value, "from_port", null) != null ? tonumber(each.value.from_port) : null
  to_port         = lookup(each.value, "to_port", null) != null ? tonumber(each.value.to_port) : null
  icmp_type       = lookup(each.value, "icmp_type", null) != null ? tonumber(each.value.icmp_type) : null
  icmp_code       = lookup(each.value, "icmp_code", null) != null ? tonumber(each.value.icmp_code) : null
}
