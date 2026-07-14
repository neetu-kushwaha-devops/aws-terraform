terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  connection_id = var.create_connection ? try(aws_dx_connection.this[0].id, "") : var.existing_connection_id
  dx_gateway_id = var.create_dx_gateway ? try(aws_dx_gateway.this[0].id, "") : var.existing_dx_gateway_id
}

resource "aws_dx_connection" "this" {
  count = var.create_connection ? 1 : 0

  name          = var.connection_name
  bandwidth     = var.bandwidth
  location      = var.location
  provider_name = var.provider_name

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_dx_gateway" "this" {
  count = var.create_dx_gateway ? 1 : 0

  name            = var.dx_gateway_name != null ? var.dx_gateway_name : "${var.connection_name}-dxgw"
  amazon_side_asn = var.dx_gateway_asn
}

resource "aws_dx_gateway_association" "this" {
  for_each = var.dx_gateway_associations

  dx_gateway_id         = local.dx_gateway_id
  associated_gateway_id = each.value.associated_gateway_id
  allowed_prefixes      = length(each.value.allowed_prefixes) > 0 ? each.value.allowed_prefixes : null
}

resource "aws_dx_private_virtual_interface" "this" {
  for_each = var.private_vifs

  connection_id    = each.value.connection_id != null ? each.value.connection_id : local.connection_id
  name             = each.value.name
  vlan             = each.value.vlan
  address_family   = each.value.address_family
  bgp_asn          = each.value.bgp_asn
  amazon_address   = each.value.amazon_address
  customer_address = each.value.customer_address
  bgp_auth_key     = each.value.bgp_auth_key

  dx_gateway_id  = each.value.vpn_gateway_id == null ? (each.value.dx_gateway_id != null ? each.value.dx_gateway_id : local.dx_gateway_id) : null
  vpn_gateway_id = each.value.vpn_gateway_id

  tags = merge(
    {
      "Name" = each.value.name
    },
    each.value.tags,
    var.tags
  )
}

resource "aws_dx_public_virtual_interface" "this" {
  for_each = var.public_vifs

  connection_id         = each.value.connection_id != null ? each.value.connection_id : local.connection_id
  name                  = each.value.name
  vlan                  = each.value.vlan
  address_family        = each.value.address_family
  bgp_asn               = each.value.bgp_asn
  amazon_address        = each.value.amazon_address
  customer_address      = each.value.customer_address
  bgp_auth_key          = each.value.bgp_auth_key
  route_filter_prefixes = each.value.route_filter_prefixes

  tags = merge(
    {
      "Name" = each.value.name
    },
    each.value.tags,
    var.tags
  )
}

resource "aws_dx_transit_virtual_interface" "this" {
  for_each = var.transit_vifs

  connection_id    = each.value.connection_id != null ? each.value.connection_id : local.connection_id
  name             = each.value.name
  vlan             = each.value.vlan
  address_family   = each.value.address_family
  bgp_asn          = each.value.bgp_asn
  amazon_address   = each.value.amazon_address
  customer_address = each.value.customer_address
  bgp_auth_key     = each.value.bgp_auth_key
  dx_gateway_id    = each.value.dx_gateway_id != null ? each.value.dx_gateway_id : local.dx_gateway_id

  tags = merge(
    {
      "Name" = each.value.name
    },
    each.value.tags,
    var.tags
  )
}
