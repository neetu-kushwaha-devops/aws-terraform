output "config_recorder_id" {
  description = "The ID of the configuration recorder"
  value       = try(aws_config_configuration_recorder.this[0].id, null)
}

output "config_recorder_role_arn" {
  description = "The ARN of the IAM role used by the configuration recorder"
  value       = var.create_iam_role ? try(aws_iam_role.config[0].arn, null) : var.iam_role_arn
}

output "config_delivery_channel_id" {
  description = "The ID of the configuration delivery channel"
  value       = try(aws_config_delivery_channel.this[0].id, null)
}

output "encrypted_volumes_rule_arn" {
  description = "The ARN of the encrypted-volumes rule"
  value       = try(aws_config_config_rule.encrypted_volumes[0].arn, null)
}

output "root_account_mfa_rule_arn" {
  description = "The ARN of the root-account-mfa rule"
  value       = try(aws_config_config_rule.root_account_mfa[0].arn, null)
}

output "custom_managed_rules_arns" {
  description = "A map of custom managed rules to their ARNs"
  value       = { for k, v in aws_config_config_rule.custom_managed : k => v.arn }
}
