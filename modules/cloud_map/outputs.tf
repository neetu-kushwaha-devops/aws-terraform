output "namespace_id" {
  description = "The ID of the service discovery namespace"
  value = coalesce(
    one(aws_service_discovery_http_namespace.this[*].id),
    one(aws_service_discovery_private_dns_namespace.this[*].id),
    one(aws_service_discovery_public_dns_namespace.this[*].id)
  )
}

output "namespace_arn" {
  description = "The ARN of the service discovery namespace"
  value = coalesce(
    one(aws_service_discovery_http_namespace.this[*].arn),
    one(aws_service_discovery_private_dns_namespace.this[*].arn),
    one(aws_service_discovery_public_dns_namespace.this[*].arn)
  )
}

output "namespace_name" {
  description = "The name of the service discovery namespace"
  value = coalesce(
    one(aws_service_discovery_http_namespace.this[*].name),
    one(aws_service_discovery_private_dns_namespace.this[*].name),
    one(aws_service_discovery_public_dns_namespace.this[*].name)
  )
}
