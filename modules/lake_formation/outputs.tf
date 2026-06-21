output "settings_id" {
  description = "The ID of the Lake Formation data lake settings."
  value       = length(aws_lakeformation_data_lake_settings.this) > 0 ? aws_lakeformation_data_lake_settings.this[0].id : null
}

output "resources_arns" {
  description = "Map of registered Lake Formation resource keys to their ARNs."
  value       = { for k, v in aws_lakeformation_resource.this : k => v.arn }
}

output "lf_tags_names" {
  description = "List of the keys of the LF-tags created."
  value       = [for k, v in aws_lakeformation_lf_tag.this : v.key]
}

output "permissions_ids" {
  description = "Map of permission keys to their generated permission resource IDs."
  value       = { for k, v in aws_lakeformation_permissions.this : k => v.id }
}

output "lf_tag_relations_ids" {
  description = "Map of LF-tag relation keys to their relation resource IDs."
  value       = { for k, v in aws_lakeformation_resource_lf_tags.this : k => v.id }
}
