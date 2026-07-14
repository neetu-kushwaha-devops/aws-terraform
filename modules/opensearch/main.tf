terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  default_cluster_config = {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = var.dedicated_master_count
    zone_awareness_enabled   = var.zone_awareness_enabled
    availability_zone_count  = var.availability_zone_count
    warm_enabled             = var.warm_enabled
    warm_type                = var.warm_type
    warm_count               = var.warm_count
  }

  # Merge default configurations with optional map overrides for compatibility
  cluster_config = merge(local.default_cluster_config, var.cluster_config)

  # Default IAM Policy for the OpenSearch Domain
  default_access_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:${data.aws_partition.current.partition}:es:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
    }
  ]
}
EOF

  access_policy = coalesce(var.custom_access_policy, local.default_access_policy)
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = local.cluster_config.instance_type
    instance_count           = local.cluster_config.instance_count
    dedicated_master_enabled = local.cluster_config.dedicated_master_enabled
    dedicated_master_type    = local.cluster_config.dedicated_master_enabled ? local.cluster_config.dedicated_master_type : null
    dedicated_master_count   = local.cluster_config.dedicated_master_enabled ? local.cluster_config.dedicated_master_count : null
    zone_awareness_enabled   = local.cluster_config.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = local.cluster_config.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = local.cluster_config.availability_zone_count
      }
    }

    warm_enabled = local.cluster_config.warm_enabled
    warm_type    = local.cluster_config.warm_enabled ? local.cluster_config.warm_type : null
    warm_count   = local.cluster_config.warm_enabled ? local.cluster_config.warm_count : null
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    iops        = var.ebs_volume_type == "gp3" ? var.ebs_iops : null
    throughput  = var.ebs_volume_type == "gp3" ? var.ebs_throughput : null
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = var.tls_security_policy
  }

  dynamic "vpc_options" {
    for_each = var.vpc_enabled ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "advanced_security_options" {
    for_each = var.fine_grained_access_control_enabled ? [1] : []
    content {
      enabled                        = true
      internal_user_database_enabled = var.master_user_arn == null ? true : false

      dynamic "master_user_options" {
        for_each = var.master_user_arn != null ? [1] : []
        content {
          master_user_arn = var.master_user_arn
        }
      }

      dynamic "master_user_options" {
        for_each = var.master_user_arn == null && var.master_user_username != null ? [1] : []
        content {
          master_user_username = var.master_user_username
          master_user_password = var.master_user_password
        }
      }
    }
  }

  access_policies = local.access_policy

  advanced_options = var.advanced_options

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options
    content {
      log_type                 = log_publishing_options.value.log_type
      cloudwatch_log_group_arn = log_publishing_options.value.log_group_arn
      enabled                  = log_publishing_options.value.enabled
    }
  }

  tags = merge({ Name = var.domain_name }, var.tags)
}
