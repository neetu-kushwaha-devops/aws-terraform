output "carrier_gateway_id" {
  description = "The ID of the carrier gateway"
  value       = aws_ec2_carrier_gateway.this.id
}

output "carrier_gateway_arn" {
  description = "The ARN of the carrier gateway"
  value       = aws_ec2_carrier_gateway.this.arn
}

output "carrier_route_table_id" {
  description = "The ID of the carrier route table"
  value       = aws_route_table.carrier.id
}

output "subnet_ids" {
  description = "Map of Wavelength subnet IDs"
  value       = { for k, v in aws_subnet.wavelength : k => v.id }
}

output "subnet_arns" {
  description = "Map of Wavelength subnet ARNs"
  value       = { for k, v in aws_subnet.wavelength : k => v.arn }
}
