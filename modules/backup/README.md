# AWS Backup Module

This module manages AWS Backup Vaults, Vault KMS encryption, Vault access policies, Backup Plans (with multiple configurable rules including schedules and lifecycle transitions), and Backup Selections (tag-based and resource ARN-based).

## Features

- AWS Backup Vault with server-side encryption (KMS Key ARN support).
- Custom Backup Vault Access Policy JSON.
- AWS Backup Plan with multiple rules, schedules, windows, and lifecycle transitions (cold storage transition, deletion retention).
- Custom tags applied to Recovery Points.
- Multiple Backup Selections via resource ARN or resource Tag mapping.
- Automatic creation of IAM Role with required AWS Backup Service and Restore permissions.

## Usage Example

```hcl
module "aws_backup" {
  source = "./modules/backup"

  vault_name = "production-backup-vault"
  plan_name  = "production-backup-plan"

  # Custom KMS encryption key
  vault_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/xxxx-xxxx-xxxx"

  # Rules configuration
  rules = [
    {
      name              = "daily-backup"
      schedule          = "cron(0 5 * * ? *)" # 5:00 AM daily
      start_window      = 60
      completion_window = 120
      lifecycle = {
        cold_storage_after = 30
        delete_after       = 90 # Retain for 90 days total
      }
    },
    {
      name              = "monthly-backup"
      schedule          = "cron(0 5 1 * ? *)" # 5:00 AM on first day of month
      start_window      = 60
      completion_window = 240
      lifecycle = {
        cold_storage_after = 90
        delete_after       = 365 # Retain for 1 year
      }
    }
  ]

  # Selections by tag and resources
  selections = {
    tag_based = {
      name      = "tag-selected-resources"
      resources = []
      selection_tags = [
        {
          type  = "STRINGEQUALS"
          key   = "Backup"
          value = "true"
        }
      ]
    }
    explicit_arn = {
      name      = "arn-selected-resources"
      resources = [
        "arn:aws:rds:us-east-1:123456789012:db:production-db"
      ]
      selection_tags = []
    }
  }

  tags = {
    Environment = "production"
    Project     = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `vault_name` | Name of the AWS Backup vault to create | `string` | n/a | yes |
| `vault_kms_key_arn` | The server-side encryption key (KMS Key ARN) used to protect your backups | `string` | `null` | no |
| `vault_policy` | The IAM policy document in JSON format to apply to the AWS Backup vault | `string` | `null` | no |
| `plan_name` | Name of the AWS Backup plan to create | `string` | n/a | yes |
| `rules` | List of maps containing backup rules configuration | `any` | `[]` (falls back to daily backup with 30-day retention) | no |
| `create_iam_role` | Whether to create a new IAM role for AWS Backup. If false, `iam_role_arn` must be provided | `bool` | `true` | no |
| `iam_role_arn` | The ARN of an existing IAM role to be used by AWS Backup if `create_iam_role` is false | `string` | `null` | no |
| `selections` | Map of backup selections to apply | `any` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `backup_vault_arn` | The ARN of the AWS Backup vault |
| `backup_vault_id` | The ID of the AWS Backup vault |
| `backup_vault_name` | The name of the AWS Backup vault |
| `backup_plan_arn` | The ARN of the AWS Backup plan |
| `backup_plan_id` | The ID of the AWS Backup plan |
| `backup_plan_version` | The version of the AWS Backup plan |
| `backup_selection_ids` | Map of backup selection IDs created |
| `backup_role_arn` | The ARN of the IAM role used for execution |
| `backup_role_name` | The name of the IAM role used for execution (if created) |
