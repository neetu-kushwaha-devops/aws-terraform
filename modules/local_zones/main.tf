resource "aws_subnet" "this" {
  for_each                = var.subnets
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.name}-localzone-${each.key}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "this" {
  for_each       = { for k, v in var.subnets : k => v if var.route_table_id != null && var.route_table_id != "" }
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = var.route_table_id
}
