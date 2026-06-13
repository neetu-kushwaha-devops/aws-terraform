output "inspector_enabler_id" {
  description = "The ID of the Inspector enabler (typically the AWS Account ID)"
  value       = try(aws_inspector2_enabler.this[0].id, null)
}

output "enabled_resource_types" {
  description = "The list of resource types enabled for Inspector v2 scanning"
  value       = local.resource_types
}
