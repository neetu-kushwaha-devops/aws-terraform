output "service_id" {
  description = "The ID of the service discovery service"
  value       = aws_service_discovery_service.this.id
}

output "service_arn" {
  description = "The ARN of the service discovery service"
  value       = aws_service_discovery_service.this.arn
}

output "service_name" {
  description = "The name of the service discovery service"
  value       = aws_service_discovery_service.this.name
}

output "registered_instances" {
  description = "A map of registered instance IDs to their attributes"
  value       = { for k, v in aws_service_discovery_instance.this : k => v.id }
}
