# Production-ready AWS NAT Gateway module
# Supports both single and multi-NAT gateway deployment topologies

locals {
  enabled   = var.enable_nat_gateway && length(var.subnet_ids) > 0
  nat_count = local.enabled ? (var.single_nat_gateway ? 1 : length(var.subnet_ids)) : 0
}

resource "aws_eip" "this" {
  count = local.enabled && var.create_eip ? local.nat_count : 0

  domain = "vpc"

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-eip" : "${var.name}-eip-${count.index}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count = local.nat_count

  allocation_id = var.create_eip ? aws_eip.this[count.index].id : var.eip_allocation_ids[count.index]
  subnet_id     = var.subnet_ids[count.index]

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? var.name : "${var.name}-${count.index}"
    },
    var.tags
  )
}
