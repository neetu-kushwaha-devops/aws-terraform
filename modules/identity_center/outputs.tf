output "permission_set_arns" {
  description = "Map of created permission set ARNs"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "permission_set_created_details" {
  description = "Detailed list of permission sets created"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.id }
}
