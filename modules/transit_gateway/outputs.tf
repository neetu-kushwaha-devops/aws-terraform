output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = try(aws_ec2_transit_gateway.this[0].id, "")
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway"
  value       = try(aws_ec2_transit_gateway.this[0].arn, "")
}

output "transit_gateway_owner_id" {
  description = "The owner ID of the Transit Gateway"
  value       = try(aws_ec2_transit_gateway.this[0].owner_id, "")
}

output "transit_gateway_association_default_route_table_id" {
  description = "The ID of the default association route table"
  value       = try(aws_ec2_transit_gateway.this[0].association_default_route_table_id, "")
}

output "transit_gateway_propagation_default_route_table_id" {
  description = "The ID of the default propagation route table"
  value       = try(aws_ec2_transit_gateway.this[0].propagation_default_route_table_id, "")
}

output "vpc_attachment_ids" {
  description = "A map of Transit Gateway VPC attachment IDs key-value pairs"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.id }
}

output "route_table_ids" {
  description = "A map of Transit Gateway custom route table IDs key-value pairs"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "ram_resource_share_id" {
  description = "The ID of the RAM resource share"
  value       = try(aws_ram_resource_share.this[0].id, "")
}
