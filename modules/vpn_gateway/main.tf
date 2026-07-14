terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_vpn_gateway" "this" {
  count = var.create_vpn_gateway ? 1 : 0

  vpc_id          = var.vpc_id
  amazon_side_asn = var.amazon_side_asn

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_customer_gateway" "this" {
  for_each = var.customer_gateways

  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.ip_address
  type       = "ipsec.1"

  tags = merge(
    {
      "Name" = each.key
    },
    each.value.tags,
    var.tags
  )
}

resource "aws_vpn_connection" "this" {
  for_each = var.vpn_connections

  vpn_gateway_id      = each.value.transit_gateway_id == null && var.create_vpn_gateway ? aws_vpn_gateway.this[0].id : null
  transit_gateway_id  = each.value.transit_gateway_id
  customer_gateway_id = try(aws_customer_gateway.this[each.value.customer_gateway_key].id, each.value.customer_gateway_key)
  type                = "ipsec.1"
  static_routes_only  = each.value.static_routes_only

  local_ipv4_network_cidr  = each.value.local_ipv4_network_cidr
  remote_ipv4_network_cidr = each.value.remote_ipv4_network_cidr

  tunnel1_inside_cidr   = each.value.tunnel1_inside_cidr
  tunnel2_inside_cidr   = each.value.tunnel2_inside_cidr
  tunnel1_preshared_key = each.value.tunnel1_preshared_key
  tunnel2_preshared_key = each.value.tunnel2_preshared_key

  tunnel1_dpd_timeout_action = each.value.tunnel1_dpd_timeout_action
  tunnel2_dpd_timeout_action = each.value.tunnel2_dpd_timeout_action

  tunnel1_ike_versions = each.value.tunnel1_ike_versions
  tunnel2_ike_versions = each.value.tunnel2_ike_versions

  tags = merge(
    {
      "Name" = each.key
    },
    each.value.tags,
    var.tags
  )
}

locals {
  vpn_static_routes = merge([
    for conn_key, conn in var.vpn_connections : {
      for route in try(conn.static_routes, []) :
      "${conn_key}_${route}" => {
        vpn_connection_id      = aws_vpn_connection.this[conn_key].id
        destination_cidr_block = route
      }
    } if try(conn.static_routes_only, false)
  ]...)
}

resource "aws_vpn_connection_route" "this" {
  for_each = local.vpn_static_routes

  destination_cidr_block = each.value.destination_cidr_block
  vpn_connection_id      = each.value.vpn_connection_id
}

resource "aws_vpn_gateway_route_propagation" "this" {
  for_each = var.create_vpn_gateway ? toset(var.route_table_ids) : []

  vpn_gateway_id = aws_vpn_gateway.this[0].id
  route_table_id = each.value
}
