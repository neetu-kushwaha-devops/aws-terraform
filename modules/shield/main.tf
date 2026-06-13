resource "aws_shield_protection" "this" {
  for_each     = var.enable ? var.protected_resources : {}
  name         = each.key
  resource_arn = each.value

  tags = merge({ Name = "${var.name}-${each.key}-protection" }, var.tags)
}

resource "aws_shield_protection_group" "this" {
  count = var.enable && var.enable_protection_group ? 1 : 0

  protection_group_id = var.protection_group_id
  aggregation         = var.protection_group_aggregation
  pattern             = var.protection_group_pattern
  resource_type       = var.protection_group_pattern == "BY_RESOURCE_TYPE" ? var.protection_group_resource_type : null

  # For ARBITRARY pattern, map members to the protected resource ARNs
  members = var.protection_group_pattern == "ARBITRARY" ? [for p in aws_shield_protection.this : p.resource_arn] : null

  tags = merge({ Name = "${var.name}-protection-group" }, var.tags)
}
