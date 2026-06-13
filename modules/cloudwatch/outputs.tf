output "log_group_arn" {
  description = "The ARN of the CloudWatch log group."
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}

output "log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
}

output "cpu_alarm_arn" {
  description = "The ARN of the CPU utilization alarm."
  value       = var.cpu_alarm_enabled ? aws_cloudwatch_metric_alarm.cpu[0].arn : null
}

output "memory_alarm_arn" {
  description = "The ARN of the Memory utilization alarm."
  value       = var.memory_alarm_enabled ? aws_cloudwatch_metric_alarm.memory[0].arn : null
}

output "billing_alarm_arn" {
  description = "The ARN of the Billing alarm."
  value       = var.billing_alarm_enabled ? aws_cloudwatch_metric_alarm.billing[0].arn : null
}

output "custom_alarm_arns" {
  description = "A map of custom alarm names to their ARNs."
  value       = { for name, alarm in aws_cloudwatch_metric_alarm.custom : name => alarm.arn }
}

output "dashboard_arn" {
  description = "The ARN of the CloudWatch dashboard."
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.this[0].dashboard_arn : null
}
