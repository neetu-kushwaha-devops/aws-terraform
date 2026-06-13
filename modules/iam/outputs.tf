output "role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value       = var.create_role ? aws_iam_role.this[0].arn : null
}

output "role_name" {
  description = "The name of the IAM role"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "role_unique_id" {
  description = "Stable and unique string identifying the role"
  value       = var.create_role ? aws_iam_role.this[0].unique_id : null
}

output "policy_arn" {
  description = "The ARN assigned by AWS to the custom policy"
  value       = var.create_policy ? aws_iam_policy.custom[0].arn : null
}

output "policy_name" {
  description = "The name of the custom IAM policy"
  value       = var.create_policy ? aws_iam_policy.custom[0].name : null
}

output "instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}

output "instance_profile_name" {
  description = "The instance profile's name"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : null
}
