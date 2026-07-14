terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "gateway" {
  for_each          = var.gateway_endpoints
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = each.value.route_table_ids
  policy            = each.value.policy

  tags = merge(
    {
      Name = "${var.name}-${each.key}-gw"
    },
    var.tags
  )
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = var.interface_endpoints
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = each.value.subnet_ids
  security_group_ids  = each.value.security_group_ids
  private_dns_enabled = each.value.private_dns_enabled
  policy              = each.value.policy

  tags = merge(
    {
      Name = "${var.name}-${each.key}-vpce"
    },
    var.tags
  )
}
