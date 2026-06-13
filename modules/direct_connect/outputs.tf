output "connection_id" {
  description = "The ID of the Direct Connect connection"
  value       = local.connection_id
}

output "connection_arn" {
  description = "The ARN of the Direct Connect connection"
  value       = try(aws_dx_connection.this[0].arn, "")
}

output "dx_gateway_id" {
  description = "The ID of the Direct Connect Gateway"
  value       = local.dx_gateway_id
}

output "dx_gateway_association_ids" {
  description = "A map of Direct Connect Gateway Association IDs"
  value       = { for k, v in aws_dx_gateway_association.this : k => v.id }
}

output "private_vif_ids" {
  description = "A map of Private Virtual Interface IDs"
  value       = { for k, v in aws_dx_private_virtual_interface.this : k => v.id }
}

output "public_vif_ids" {
  description = "A map of Public Virtual Interface IDs"
  value       = { for k, v in aws_dx_public_virtual_interface.this : k => v.id }
}

output "transit_vif_ids" {
  description = "A map of Transit Virtual Interface IDs"
  value       = { for k, v in aws_dx_transit_virtual_interface.this : k => v.id }
}
