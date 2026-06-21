output "accelerator_id" {
  description = "The ID of the accelerator"
  value       = aws_globalaccelerator_accelerator.this.id
}

output "accelerator_arn" {
  description = "The ARN of the accelerator"
  value       = aws_globalaccelerator_accelerator.this.arn
}

output "dns_name" {
  description = "The DNS name of the accelerator"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "ip_sets" {
  description = "The IP address sets associated with the accelerator"
  value       = aws_globalaccelerator_accelerator.this.ip_sets
}

output "listener_ids" {
  description = "Map of listener IDs"
  value       = { for k, v in aws_globalaccelerator_listener.this : k => v.id }
}

output "endpoint_group_ids" {
  description = "Map of endpoint group IDs"
  value       = { for k, v in aws_globalaccelerator_endpoint_group.this : k => v.id }
}
