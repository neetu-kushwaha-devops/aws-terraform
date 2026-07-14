terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Production-ready AWS Route Tables module
# Manages route tables, dynamic routes targeting various destination gateways, and subnet associations

resource "aws_route_table" "this" {
  for_each = var.route_tables

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.name}-${coalesce(each.value.name, each.key)}"
    },
    var.tags,
    each.value.tags
  )
}

locals {
  # Flatten route tables and their routes
  routes_flat = flatten([
    for rt_key, rt in var.route_tables : [
      for idx, route in rt.routes : {
        key                         = "${rt_key}_route_${idx}"
        route_table_id              = aws_route_table.this[rt_key].id
        destination_cidr_block      = route.cidr_block
        destination_ipv6_cidr_block = route.ipv6_cidr_block
        destination_prefix_list_id  = route.destination_prefix_list_id
        gateway_id                  = route.gateway_id
        nat_gateway_id              = route.nat_gateway_id
        transit_gateway_id          = route.transit_gateway_id
        vpc_peering_connection_id   = route.vpc_peering_connection_id
        egress_only_gateway_id      = route.egress_only_gateway_id
        network_interface_id        = route.network_interface_id
        vpc_endpoint_id             = route.vpc_endpoint_id
      }
    ]
  ])

  # Flatten route tables and their subnet associations
  associations_flat = flatten([
    for rt_key, rt in var.route_tables : [
      for subnet in rt.subnets : {
        key            = "${rt_key}_subnet_${subnet}"
        route_table_id = aws_route_table.this[rt_key].id
        subnet_id      = subnet
      }
    ]
  ])
}

resource "aws_route" "this" {
  for_each = { for r in local.routes_flat : r.key => r }

  route_table_id              = each.value.route_table_id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  destination_prefix_list_id  = each.value.destination_prefix_list_id
  gateway_id                  = each.value.gateway_id
  nat_gateway_id              = each.value.nat_gateway_id
  transit_gateway_id          = each.value.transit_gateway_id
  vpc_peering_connection_id   = each.value.vpc_peering_connection_id
  egress_only_gateway_id      = each.value.egress_only_gateway_id
  network_interface_id        = each.value.network_interface_id
  vpc_endpoint_id             = each.value.vpc_endpoint_id

  lifecycle {
    precondition {
      condition = (
        (each.value.destination_cidr_block != null ? 1 : 0) +
        (each.value.destination_ipv6_cidr_block != null ? 1 : 0) +
        (each.value.destination_prefix_list_id != null ? 1 : 0)
      ) == 1
      error_message = "Each route must specify exactly one destination: cidr_block, ipv6_cidr_block, or destination_prefix_list_id."
    }
  }
}

resource "aws_route_table_association" "this" {
  for_each = { for a in local.associations_flat : a.key => a }

  route_table_id = each.value.route_table_id
  subnet_id      = each.value.subnet_id
}
