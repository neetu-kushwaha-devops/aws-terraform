output "web_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "The ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_name" {
  description = "The name of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.this.name
}

output "log_group_name" {
  description = "The name of the CloudWatch Log Group created for WAF logs"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch Log Group created for WAF logs"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}
