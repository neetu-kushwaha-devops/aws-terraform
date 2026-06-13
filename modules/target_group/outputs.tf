output "target_group_id" {
  description = "The ID of the target group"
  value       = aws_lb_target_group.this.id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.this.name
}

output "target_group_arn_suffix" {
  description = "The ARN suffix of the target group (useful for CloudWatch metrics/alarms)"
  value       = aws_lb_target_group.this.arn_suffix
}

output "attachments" {
  description = "A map of targets attached to the target group"
  value       = { for k, v in aws_lb_target_group_attachment.this : k => v.id }
}
