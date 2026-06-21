output "gateway_endpoint_ids" {
  description = "A map of Gateway Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}

output "interface_endpoint_ids" {
  description = "A map of Interface Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "interface_endpoint_dns" {
  description = "A map of Interface Endpoint DNS entries"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.dns_entry }
}
