output "file_system_id" {
  description = "The ID of the EFS file system."
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "The ARN of the EFS file system."
  value       = aws_efs_file_system.this.arn
}

output "file_system_dns_name" {
  description = "The DNS name for the EFS file system."
  value       = aws_efs_file_system.this.dns_name
}

output "mount_targets" {
  description = "A map of mount targets created, keyed by subnet ID."
  value = {
    for subnet_id, target in aws_efs_mount_target.this : subnet_id => {
      id                = target.id
      dns_name          = target.mount_target_dns_name
      network_interface = target.network_interface_id
    }
  }
}
