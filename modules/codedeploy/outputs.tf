output "app_name" {
  description = "The name of the CodeDeploy application"
  value       = aws_codedeploy_app.this.name
}

output "app_id" {
  description = "The ID of the CodeDeploy application"
  value       = aws_codedeploy_app.this.id
}

output "deployment_group_name" {
  description = "The name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "deployment_group_id" {
  description = "The ID of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.this.id
}

output "service_role_arn" {
  description = "The ARN of the IAM role used by CodeDeploy"
  value       = var.create_service_role ? aws_iam_role.codedeploy[0].arn : var.service_role_arn
}

output "service_role_name" {
  description = "The name of the IAM role used by CodeDeploy"
  value       = var.create_service_role ? aws_iam_role.codedeploy[0].name : null
}
