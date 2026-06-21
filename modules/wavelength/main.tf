resource "aws_ec2_carrier_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.name}-cgw"
    },
    var.tags
  )
}

resource "aws_route_table" "carrier" {
  vpc_id = var.vpc_id

  route {
    cidr_block         = "0.0.0.0/0"
    carrier_gateway_id = aws_ec2_carrier_gateway.this.id
  }

  tags = merge(
    {
      Name = "${var.name}-carrier-rt"
    },
    var.tags
  )
}

resource "aws_subnet" "wavelength" {
  for_each          = var.subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    {
      Name = "${var.name}-wavelength-${each.key}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "wavelength" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.wavelength[each.key].id
  route_table_id = aws_route_table.carrier.id
}
