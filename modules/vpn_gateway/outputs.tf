output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = try(aws_vpn_gateway.this[0].id, "")
}

output "vpn_gateway_arn" {
  description = "The ARN of the VPN Gateway"
  value       = try(aws_vpn_gateway.this[0].arn, "")
}

output "customer_gateway_ids" {
  description = "A map of customer gateway IDs key-value pairs"
  value       = { for k, v in aws_customer_gateway.this : k => v.id }
}

output "vpn_connection_ids" {
  description = "A map of VPN connection IDs key-value pairs"
  value       = { for k, v in aws_vpn_connection.this : k => v.id }
}

output "vpn_connection_tunnel1_address" {
  description = "A map of the first tunnel public IP addresses for the VPN connections"
  value       = { for k, v in aws_vpn_connection.this : k => v.tunnel1_address }
}

output "vpn_connection_tunnel2_address" {
  description = "A map of the second tunnel public IP addresses for the VPN connections"
  value       = { for k, v in aws_vpn_connection.this : k => v.tunnel2_address }
}
