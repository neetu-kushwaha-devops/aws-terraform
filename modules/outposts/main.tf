resource "aws_subnet" "outpost" {
  vpc_id                          = var.vpc_id
  cidr_block                      = var.cidr_block
  outpost_arn                     = var.outpost_arn
  customer_owned_ipv4_pool        = var.customer_owned_ipv4_pool
  map_customer_owned_ip_on_launch = var.map_customer_owned_ip_on_launch

  tags = merge(
    {
      Name = "${var.name}-outpost-subnet"
    },
    var.tags
  )
}

resource "aws_network_interface" "this" {
  for_each    = var.network_interfaces
  subnet_id   = aws_subnet.outpost.id
  description = each.value.description
  private_ips = each.value.private_ips

  tags = merge(
    {
      Name = "${var.name}-lni-${each.key}"
    },
    var.tags
  )
}
