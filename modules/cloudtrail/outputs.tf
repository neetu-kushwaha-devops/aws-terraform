output "cloudtrail_id" {
  description = "The name of the trail."
  value       = aws_cloudtrail.this.id
}

output "cloudtrail_arn" {
  description = "The ARN of the trail."
  value       = aws_cloudtrail.this.arn
}

output "cloudtrail_home_region" {
  description = "The region in which the trail was created."
  value       = aws_cloudtrail.this.home_region
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group."
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].arn : var.cloudwatch_logs_group_arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].name : null
}
