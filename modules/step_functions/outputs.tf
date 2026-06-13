output "state_machine_arn" {
  description = "The ARN of the Step Functions State Machine"
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_id" {
  description = "The ID of the Step Functions State Machine"
  value       = aws_sfn_state_machine.this.id
}

output "state_machine_name" {
  description = "The Name of the Step Functions State Machine"
  value       = aws_sfn_state_machine.this.name
}

output "role_arn" {
  description = "The ARN of the IAM execution role"
  value       = var.create_role ? aws_iam_role.this[0].arn : var.role_arn
}

output "role_name" {
  description = "The name of the IAM execution role"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for execution logs"
  value       = var.enable_logging ? aws_cloudwatch_log_group.sfn[0].arn : null
}
