terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_service_discovery_service" "this" {
  name         = var.name
  namespace_id = var.namespace_id

  dynamic "dns_config" {
    for_each = var.dns_config != null ? [var.dns_config] : []
    content {
      namespace_id   = var.namespace_id
      routing_policy = dns_config.value.routing_policy

      dynamic "dns_records" {
        for_each = dns_config.value.dns_records
        content {
          ttl  = dns_records.value.ttl
          type = dns_records.value.type
        }
      }
    }
  }

  dynamic "health_check_config" {
    for_each = var.health_check_config != null ? [var.health_check_config] : []
    content {
      failure_threshold = health_check_config.value.failure_threshold
      resource_path     = health_check_config.value.resource_path
      type              = health_check_config.value.type
    }
  }

  dynamic "health_check_custom_config" {
    for_each = var.health_check_custom_config != null ? [var.health_check_custom_config] : []
    content {
      failure_threshold = health_check_custom_config.value.failure_threshold
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_service_discovery_instance" "this" {
  for_each    = var.instances
  instance_id = each.key
  service_id  = aws_service_discovery_service.this.id
  attributes  = each.value.attributes
}
