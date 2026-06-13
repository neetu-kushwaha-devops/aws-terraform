output "protection_ids" {
  description = "A map of resource names to their Shield protection IDs"
  value       = { for k, v in aws_shield_protection.this : k => v.id }
}

output "protection_arns" {
  description = "A map of resource names to their Shield protection ARNs"
  value       = { for k, v in aws_shield_protection.this : k => v.arn }
}

output "protection_group_id" {
  description = "The ID of the Shield protection group"
  value       = try(aws_shield_protection_group.this[0].id, null)
}

output "protection_group_arn" {
  description = "The ARN of the Shield protection group"
  value       = try(aws_shield_protection_group.this[0].protection_group_arn, null)
}
