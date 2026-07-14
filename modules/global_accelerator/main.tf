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
  endpoint_groups = merge([
    for l_key, l_val in var.listeners : {
      for eg_key, eg_val in l_val.endpoint_groups : "${l_key}.${eg_key}" => merge(eg_val, { listener_key = l_key })
    }
  ]...)
}

resource "aws_globalaccelerator_accelerator" "this" {
  name            = var.name
  ip_address_type = var.ip_address_type
  enabled         = var.enabled

  dynamic "attributes" {
    for_each = var.flow_logs_enabled ? [1] : []
    content {
      flow_logs_enabled   = true
      flow_logs_s3_bucket = var.flow_logs_s3_bucket
      flow_logs_s3_prefix = var.flow_logs_s3_prefix
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_globalaccelerator_listener" "this" {
  for_each        = var.listeners
  accelerator_arn = aws_globalaccelerator_accelerator.this.arn
  client_affinity = "NONE"
  protocol        = each.value.protocol

  dynamic "port_range" {
    for_each = each.value.port_ranges
    content {
      from_port = port_range.value.from_port
      to_port   = port_range.value.to_port
    }
  }
}

resource "aws_globalaccelerator_endpoint_group" "this" {
  for_each              = local.endpoint_groups
  listener_arn          = aws_globalaccelerator_listener.this[each.value.listener_key].id
  endpoint_group_region = each.value.endpoint_group_region

  health_check_port             = each.value.health_check_port
  health_check_protocol         = each.value.health_check_protocol
  health_check_path             = each.value.health_check_path
  health_check_interval_seconds = each.value.health_check_interval
  threshold_count               = each.value.threshold_count

  dynamic "endpoint_configuration" {
    for_each = each.value.endpoints
    content {
      endpoint_id                    = endpoint_configuration.value.endpoint_id
      weight                         = endpoint_configuration.value.weight
      client_ip_preservation_enabled = endpoint_configuration.value.client_ip_preservation_enabled
    }
  }
}
