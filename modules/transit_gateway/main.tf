terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_ec2_transit_gateway" "this" {
  count = var.create_tgw ? 1 : 0

  description                     = var.description != null ? var.description : var.name
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  multicast_support               = var.multicast_support
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this[0].id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  dns_support                                     = each.value.dns_support
  ipv6_support                                    = each.value.ipv6_support
  appliance_mode_support                          = each.value.appliance_mode_support
  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation

  tags = merge(
    {
      "Name" = each.key
    },
    each.value.tags,
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.this[0].id

  tags = merge(
    {
      "Name" = each.value.name
    },
    each.value.tags,
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.route_table_associations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = var.route_table_propagations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = var.static_routes

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = each.value.blackhole ? null : aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id
  blackhole                      = each.value.blackhole
}

# RAM Sharing
resource "aws_ram_resource_share" "this" {
  count = var.create_tgw && var.share_tgw ? 1 : 0

  name                      = var.ram_resource_share_name != null ? var.ram_resource_share_name : "${var.name}-share"
  allow_external_principals = true

  tags = merge(
    {
      "Name" = var.ram_resource_share_name != null ? var.ram_resource_share_name : "${var.name}-share"
    },
    var.tags
  )
}

resource "aws_ram_resource_association" "this" {
  count = var.create_tgw && var.share_tgw ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.this[0].arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "this" {
  for_each = var.create_tgw && var.share_tgw ? toset(var.ram_principals) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
