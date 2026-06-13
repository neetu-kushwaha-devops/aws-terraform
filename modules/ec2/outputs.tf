output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "public_ip" {
  description = "The public IP address assigned to the instance, or EIP if associated"
  value       = var.associate_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value       = aws_instance.this.private_ip
}

output "key_pair_name" {
  description = "The name of the key pair"
  value       = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name
}

output "key_pair_arn" {
  description = "The ARN of the key pair"
  value       = var.create_key_pair ? aws_key_pair.this[0].arn : null
}

output "eip_public_ip" {
  description = "The Elastic IP address associated with the instance"
  value       = var.associate_eip ? aws_eip.this[0].public_ip : null
}

output "eip_allocation_id" {
  description = "The Allocation ID of the Elastic IP"
  value       = var.associate_eip ? aws_eip.this[0].id : null
}
