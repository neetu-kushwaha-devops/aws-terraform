output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "sns_topic_id" {
  description = "The ID of the SNS topic"
  value       = aws_sns_topic.this.id
}

output "sns_topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "sns_topic_owner" {
  description = "The owner of the SNS topic"
  value       = aws_sns_topic.this.owner
}

output "subscription_arns" {
  description = "Map of subscription ARNs created"
  value       = { for k, v in aws_sns_topic_subscription.this : k => v.arn }
}
