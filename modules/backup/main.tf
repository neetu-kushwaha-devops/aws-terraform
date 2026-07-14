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

locals {
  backup_role_arn = var.create_iam_role ? aws_iam_role.backup[0].arn : var.iam_role_arn
}

resource "aws_iam_role" "backup" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.plan_name}-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "backup" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup[0].name
}

resource "aws_iam_role_policy_attachment" "restore" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup[0].name
}

resource "aws_backup_vault" "this" {
  name        = var.vault_name
  kms_key_arn = var.vault_kms_key_arn
  tags        = merge({ Name = "${var.name}-vault" }, var.tags)
}

resource "aws_backup_vault_policy" "this" {
  count = var.vault_policy != null ? 1 : 0

  backup_vault_name = aws_backup_vault.this.name
  policy            = var.vault_policy
}

resource "aws_backup_plan" "this" {
  name = var.plan_name

  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name         = rule.value.name
      target_vault_name = aws_backup_vault.this.name
      schedule          = lookup(rule.value, "schedule", null)
      start_window      = lookup(rule.value, "start_window", null)
      completion_window = lookup(rule.value, "completion_window", null)

      dynamic "lifecycle" {
        for_each = (lookup(rule.value, "lifecycle", null) != null &&
          (lookup(rule.value.lifecycle, "cold_storage_after", null) != null ||
        lookup(rule.value.lifecycle, "delete_after", null) != null)) ? [rule.value.lifecycle] : []
        content {
          cold_storage_after = lookup(lifecycle.value, "cold_storage_after", null)
          delete_after       = lookup(lifecycle.value, "delete_after", null)
        }
      }

      recovery_point_tags = lookup(rule.value, "recovery_point_tags", var.tags)
    }
  }

  tags = merge({ Name = "${var.name}-plan" }, var.tags)
}

resource "aws_backup_selection" "this" {
  for_each = var.selections

  iam_role_arn = local.backup_role_arn
  name         = each.value.name
  plan_id      = aws_backup_plan.this.id

  resources = lookup(each.value, "resources", null)

  dynamic "selection_tag" {
    for_each = lookup(each.value, "selection_tags", [])
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }
}
