output "broker_id" {
  description = "The ID of the Amazon MQ broker"
  value       = aws_mq_broker.this.id
}

output "broker_arn" {
  description = "The ARN of the Amazon MQ broker"
  value       = aws_mq_broker.this.arn
}

output "broker_instances_endpoints" {
  description = "A list of connection endpoints for each broker instance"
  value       = try(aws_mq_broker.this.instances[*].endpoints, [])
}

output "broker_console_url" {
  description = "The console URL of the Amazon MQ broker"
  value       = try(aws_mq_broker.this.instances[0].console_url, null)
}

output "configuration_id" {
  description = "The ID of the custom Amazon MQ configuration (if created)"
  value       = var.create_configuration ? aws_mq_configuration.this[0].id : null
}

output "configuration_arn" {
  description = "The ARN of the custom Amazon MQ configuration (if created)"
  value       = var.create_configuration ? aws_mq_configuration.this[0].arn : null
}

output "security_group_id" {
  description = "The ID of the created security group (if create_security_group is true)"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}
