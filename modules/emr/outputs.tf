output "cluster_id" {
  description = "The ID of the EMR cluster"
  value       = aws_emr_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the EMR cluster"
  value       = aws_emr_cluster.this.arn
}

output "master_public_dns" {
  description = "The public DNS name of the master node"
  value       = aws_emr_cluster.this.master_public_dns
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = local.kms_key_arn
}

output "security_configuration_name" {
  description = "The name of the security configuration associated with the cluster"
  value       = var.create_security_configuration ? (length(aws_emr_security_configuration.this) > 0 ? aws_emr_security_configuration.this[0].name : null) : var.security_configuration_name
}

output "service_role_arn" {
  description = "The ARN of the IAM service role used by EMR"
  value       = local.service_role_arn
}

output "instance_profile_arn" {
  description = "The ARN of the IAM instance profile used by the EC2 instances"
  value       = var.create_instance_profile ? (length(aws_iam_instance_profile.emr_ec2) > 0 ? aws_iam_instance_profile.emr_ec2[0].arn : null) : var.instance_profile_name_or_arn
}
