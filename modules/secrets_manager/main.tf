terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.name_prefix == null ? var.name : null
  name_prefix             = var.name_prefix
  description             = var.description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  dynamic "replica" {
    for_each = var.replicas
    content {
      region     = replica.value.region
      kms_key_id = lookup(replica.value, "kms_key_id", null)
    }
  }

  tags = merge(
    {
      "Name" = coalesce(var.name, var.name_prefix, "secrets-manager-secret")
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.secret_string != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}

resource "aws_secretsmanager_secret_policy" "this" {
  count = var.policy != null ? 1 : 0

  secret_arn          = aws_secretsmanager_secret.this.arn
  policy              = var.policy
  block_public_policy = var.block_public_policy
}

resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation_lambda_arn

  dynamic "rotation_rules" {
    for_each = var.rotation_rules != null ? [var.rotation_rules] : []
    content {
      automatically_after_days = lookup(rotation_rules.value, "automatically_after_days", null)
      duration                 = lookup(rotation_rules.value, "duration", null)
      schedule_expression      = lookup(rotation_rules.value, "schedule_expression", null)
    }
  }
}
