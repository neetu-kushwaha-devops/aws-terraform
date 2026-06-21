output "public_ips" {
  description = "List of public IP addresses assigned to the Elastic IPs"
  value       = aws_eip.this[*].public_ip
}

output "allocation_ids" {
  description = "List of allocation IDs of the Elastic IPs"
  value       = aws_eip.this[*].id
}

output "association_ids" {
  description = "List of association IDs of the Elastic IP associations"
  value       = aws_eip_association.this[*].id
}
