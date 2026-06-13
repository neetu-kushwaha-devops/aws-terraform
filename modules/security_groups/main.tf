resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress
    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null) != null ? split(",", ingress.value["cidr_blocks"]) : (lookup(ingress.value, "cidr_block", null) != null ? [ingress.value["cidr_block"]] : null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null) != null ? split(",", ingress.value["ipv6_cidr_blocks"]) : (lookup(ingress.value, "ipv6_cidr_block", null) != null ? [ingress.value["ipv6_cidr_block"]] : null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null) != null ? split(",", ingress.value["prefix_list_ids"]) : null
      security_groups  = lookup(ingress.value, "security_groups", null) != null ? split(",", ingress.value["security_groups"]) : (lookup(ingress.value, "security_group_id", null) != null ? [ingress.value["security_group_id"]] : null)
      self             = lookup(ingress.value, "self", null) != null ? tobool(ingress.value["self"]) : null
    }
  }

  dynamic "egress" {
    for_each = var.egress
    content {
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null) != null ? split(",", egress.value["cidr_blocks"]) : (lookup(egress.value, "cidr_block", null) != null ? [egress.value["cidr_block"]] : null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null) != null ? split(",", egress.value["ipv6_cidr_blocks"]) : (lookup(egress.value, "ipv6_cidr_block", null) != null ? [egress.value["ipv6_cidr_block"]] : null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null) != null ? split(",", egress.value["prefix_list_ids"]) : null
      security_groups  = lookup(egress.value, "security_groups", null) != null ? split(",", egress.value["security_groups"]) : (lookup(egress.value, "security_group_id", null) != null ? [egress.value["security_group_id"]] : null)
      self             = lookup(egress.value, "self", null) != null ? tobool(egress.value["self"]) : null
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
