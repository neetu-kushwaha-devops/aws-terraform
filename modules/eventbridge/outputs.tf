output "rule_arn" {
  description = "The ARN of the EventBridge Rule"
  value       = aws_cloudwatch_event_rule.this.arn
}

output "rule_id" {
  description = "The ID/Name of the EventBridge Rule"
  value       = aws_cloudwatch_event_rule.this.id
}

output "rule_name" {
  description = "The Name of the EventBridge Rule"
  value       = aws_cloudwatch_event_rule.this.name
}

output "bus_arn" {
  description = "The ARN of the EventBridge Bus"
  value       = var.create_bus ? aws_cloudwatch_event_bus.this[0].arn : null
}

output "bus_name" {
  description = "The Name of the EventBridge Bus used or created"
  value       = var.create_bus ? aws_cloudwatch_event_bus.this[0].name : var.bus_name
}

output "target_ids" {
  description = "The Map of target IDs created"
  value       = [for k, v in aws_cloudwatch_event_target.this : v.target_id]
}

output "target_role_arn" {
  description = "The ARN of the generated IAM execution role for targets"
  value       = var.create_target_role ? aws_iam_role.target[0].arn : null
}
