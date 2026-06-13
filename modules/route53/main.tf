resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.zone_name
  tags = merge({ Name = var.zone_name }, var.tags)

  dynamic "vpc" {
    for_each = var.private_zone ? var.vpc_ids : []
    content {
      vpc_id     = vpc.value
      vpc_region = lookup(var.vpc_regions, vpc.value, null)
    }
  }
}

locals {
  # Generate unique keys for records to support multiple records of the same type/name for routing policies
  record_map = {
    for idx, r in var.records :
    "${r.name}_${r.type}_${r.set_identifier != null ? r.set_identifier : tostring(idx)}" => r
  }
}

resource "aws_route53_record" "this" {
  for_each = local.record_map

  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.existing_zone_id

  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.alias == null ? coalesce(each.value.ttl, 300) : null
  records = each.value.alias == null ? each.value.records : null

  set_identifier  = each.value.set_identifier
  health_check_id = each.value.health_check_id

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }
}
