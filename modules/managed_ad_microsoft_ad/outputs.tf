output "directory_id" {
  description = "The ID of the directory"
  value       = aws_directory_service_directory.this.id
}

output "directory_dns_ips" {
  description = "The IP addresses of the DNS servers for the directory"
  value       = aws_directory_service_directory.this.dns_ip_addresses
}

output "directory_security_group_id" {
  description = "The security group ID created by AWS for the directory controllers"
  value       = aws_directory_service_directory.this.security_group_id
}
