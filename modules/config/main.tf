terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_partition" "current" {}

resource "aws_iam_role" "config" {
  count = var.enable && var.create_iam_role ? 1 : 0
  name  = var.iam_role_name != null ? var.iam_role_name : "${var.recorder_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  count      = var.enable && var.create_iam_role ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config_s3" {
  count = var.enable && var.create_iam_role && var.delivery_s3_bucket != null ? 1 : 0
  name  = "${var.recorder_name}-s3-policy"
  role  = aws_iam_role.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${var.delivery_s3_bucket}",
          "arn:${data.aws_partition.current.partition}:s3:::${var.delivery_s3_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "this" {
  count    = var.enable ? 1 : 0
  name     = var.recorder_name
  role_arn = var.create_iam_role ? aws_iam_role.config[0].arn : var.iam_role_arn

  recording_group {
    all_supported                 = var.recording_group_all_supported
    include_global_resource_types = var.recording_group_include_global_resource_types
  }
}

resource "aws_config_delivery_channel" "this" {
  count          = var.enable && var.delivery_s3_bucket != null ? 1 : 0
  name           = var.delivery_channel_name
  s3_bucket_name = var.delivery_s3_bucket
  s3_key_prefix  = var.delivery_s3_key_prefix

  dynamic "snapshot_delivery_properties" {
    for_each = var.snapshot_delivery_frequency != null ? [1] : []
    content {
      delivery_frequency = var.snapshot_delivery_frequency
    }
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count      = var.enable ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = var.recorder_is_enabled

  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  count = var.enable && var.enable_encrypted_volumes_rule ? 1 : 0
  name  = "encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_configuration_recorder_status.this]
  tags       = merge({ Name = "${var.name}-encrypted-volumes-rule" }, var.tags)
}

resource "aws_config_config_rule" "root_account_mfa" {
  count = var.enable && var.enable_root_account_mfa_rule ? 1 : 0
  name  = "root-account-mfa"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA"
  }

  depends_on = [aws_config_configuration_recorder_status.this]
  tags       = merge({ Name = "${var.name}-root-mfa-rule" }, var.tags)
}

resource "aws_config_config_rule" "custom_managed" {
  for_each = var.enable ? var.custom_managed_rules : {}
  name     = each.key

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  input_parameters = lookup(each.value, "input_parameters", null)

  depends_on = [aws_config_configuration_recorder_status.this]
  tags       = merge({ Name = "${var.name}-${each.key}-rule" }, var.tags)
}
