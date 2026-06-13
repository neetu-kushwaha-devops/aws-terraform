output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault"
  value       = aws_backup_vault.this.arn
}

output "backup_vault_id" {
  description = "The ID of the AWS Backup vault"
  value       = aws_backup_vault.this.id
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault"
  value       = aws_backup_vault.this.name
}

output "backup_plan_arn" {
  description = "The ARN of the AWS Backup plan"
  value       = aws_backup_plan.this.arn
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan"
  value       = aws_backup_plan.this.id
}

output "backup_plan_version" {
  description = "The version of the AWS Backup plan"
  value       = aws_backup_plan.this.version
}

output "backup_selection_ids" {
  description = "Map of backup selection IDs created"
  value       = { for k, v in aws_backup_selection.this : k => v.id }
}

output "backup_role_arn" {
  description = "The ARN of the IAM role used for execution"
  value       = local.backup_role_arn
}

output "backup_role_name" {
  description = "The name of the IAM role used for execution (if created)"
  value       = var.create_iam_role ? aws_iam_role.backup[0].name : null
}
