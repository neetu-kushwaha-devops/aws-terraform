output "instance_id" {
  description = "The ID of the Verified Access instance"
  value       = aws_verifiedaccess_instance.this.id
}

output "instance_arn" {
  description = "The ARN of the Verified Access instance"
  value       = aws_verifiedaccess_instance.this.arn
}

output "trust_provider_ids" {
  description = "Map of trust provider IDs"
  value       = { for k, v in aws_verifiedaccess_trust_provider.this : k => v.id }
}

output "group_ids" {
  description = "Map of group IDs"
  value       = { for k, v in aws_verifiedaccess_group.this : k => v.id }
}

output "endpoint_ids" {
  description = "Map of endpoint IDs"
  value       = { for k, v in aws_verifiedaccess_endpoint.this : k => v.id }
}
