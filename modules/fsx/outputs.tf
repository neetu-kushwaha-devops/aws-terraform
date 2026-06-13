output "file_system_id" {
  description = "The ID of the FSx file system."
  value       = aws_fsx_lustre_file_system.this.id
}

output "file_system_arn" {
  description = "The ARN of the FSx file system."
  value       = aws_fsx_lustre_file_system.this.arn
}

output "file_system_dns_name" {
  description = "The DNS name for the FSx file system."
  value       = aws_fsx_lustre_file_system.this.dns_name
}

output "mount_name" {
  description = "The mount name of the FSx file system."
  value       = aws_fsx_lustre_file_system.this.mount_name
}

output "network_interface_ids" {
  description = "A list of network interface IDs on the file system."
  value       = aws_fsx_lustre_file_system.this.network_interface_ids
}
