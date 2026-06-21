output "group_name" {
  description = "The name of the resource group."
  value       = aws_resourcegroups_group.this.name
}

output "group_arn" {
  description = "The ARN of the resource group."
  value       = aws_resourcegroups_group.this.arn
}
