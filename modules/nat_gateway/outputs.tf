output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_ips" {
  description = "List of public IPs of the NAT Gateways"
  value       = var.create_eip ? aws_eip.this[*].public_ip : []
}

output "eip_allocation_ids" {
  description = "List of Elastic IP allocation IDs used by the NAT Gateways"
  value       = var.create_eip ? aws_eip.this[*].id : var.eip_allocation_ids
}
