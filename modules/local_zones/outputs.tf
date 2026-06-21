output "subnet_ids" {
  description = "Map of Local Zone subnet IDs"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "subnet_arns" {
  description = "Map of Local Zone subnet ARNs"
  value       = { for k, v in aws_subnet.this : k => v.arn }
}
