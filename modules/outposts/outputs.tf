output "subnet_id" {
  description = "The ID of the Outpost subnet"
  value       = aws_subnet.outpost.id
}

output "subnet_arn" {
  description = "The ARN of the Outpost subnet"
  value       = aws_subnet.outpost.arn
}

output "network_interface_ids" {
  description = "Map of network interface IDs created"
  value       = { for k, v in aws_network_interface.this : k => v.id }
}
