terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_mq_configuration" "this" {
  count          = var.create_configuration ? 1 : 0
  name           = coalesce(var.configuration_name, "${var.name}-config")
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = var.configuration_data

  tags = merge(
    {
      Name = coalesce(var.configuration_name, "${var.name}-config")
    },
    var.tags
  )
}

resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-sg"
  description = "Security group for Amazon MQ broker ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.name}-sg"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "this" {
  for_each = var.create_security_group ? { for idx, rule in var.security_group_rules : idx => rule } : {}

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  self                     = lookup(each.value, "self", null)
  description              = lookup(each.value, "description", null)
  security_group_id        = aws_security_group.this[0].id
}

resource "aws_mq_broker" "this" {
  broker_name             = var.name
  engine_type             = var.engine_type
  engine_version          = var.engine_version
  host_instance_type      = var.host_instance_type
  deployment_mode         = var.deployment_mode
  storage_type            = var.storage_type
  authentication_strategy = var.authentication_strategy
  publicly_accessible     = var.publicly_accessible
  subnet_ids              = var.subnet_ids

  security_groups = compact(concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.security_groups
  ))

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  encryption_options {
    kms_key_id        = var.kms_key_arn
    use_aws_owned_key = var.kms_key_arn == null || var.kms_key_arn == "" ? true : false
  }

  dynamic "configuration" {
    for_each = var.create_configuration || var.configuration_id != null ? [1] : []
    content {
      id       = var.create_configuration ? aws_mq_configuration.this[0].id : var.configuration_id
      revision = var.create_configuration ? aws_mq_configuration.this[0].latest_revision : var.configuration_revision
    }
  }

  dynamic "user" {
    for_each = var.users
    content {
      username       = user.value.username
      password       = user.value.password
      groups         = lookup(user.value, "groups", null)
      console_access = lookup(user.value, "console_access", null)
    }
  }

  dynamic "logs" {
    for_each = var.general_log_enabled || var.audit_log_enabled ? [1] : []
    content {
      general = var.general_log_enabled
      audit   = var.engine_type == "ActiveMQ" ? var.audit_log_enabled : null
    }
  }

  dynamic "maintenance_window_start_time" {
    for_each = var.maintenance_window_start_time != null ? [var.maintenance_window_start_time] : []
    content {
      day_of_week = maintenance_window_start_time.value.day_of_week
      time_of_day = maintenance_window_start_time.value.time_of_day
      time_zone   = lookup(maintenance_window_start_time.value, "time_zone", "UTC")
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
