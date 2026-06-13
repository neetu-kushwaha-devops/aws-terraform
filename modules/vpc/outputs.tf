output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_default_security_group.default.id
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block assigned to the VPC"
  value       = aws_vpc.this.ipv6_cidr_block
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = aws_vpc.this.ipv6_association_id
}
