output "route_table_ids" {
  description = "Map of logical keys to Route Table IDs"
  value       = { for k, rt in aws_route_table.this : k => rt.id }
}

output "route_table_arns" {
  description = "Map of logical keys to Route Table ARNs"
  value       = { for k, rt in aws_route_table.this : k => rt.arn }
}

output "route_tables" {
  description = "Full map of created route table resources"
  value       = aws_route_table.this
}

output "route_table_id" {
  description = "The first created Route Table ID (for backwards compatibility)"
  value       = length(keys(aws_route_table.this)) > 0 ? aws_route_table.this[keys(aws_route_table.this)[0]].id : null
}
