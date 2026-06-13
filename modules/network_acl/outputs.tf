output "network_acl_id" {
  description = "The ID of the network ACL"
  value       = aws_network_acl.this.id
}

output "network_acl_arn" {
  description = "The ARN of the network ACL"
  value       = aws_network_acl.this.arn
}
