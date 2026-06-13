output "project_name" {
  description = "The name of the CodeBuild project"
  value       = aws_codebuild_project.this.name
}

output "project_arn" {
  description = "The ARN of the CodeBuild project"
  value       = aws_codebuild_project.this.arn
}

output "role_arn" {
  description = "The ARN of the IAM service role used by CodeBuild"
  value       = aws_iam_role.codebuild.arn
}

output "role_name" {
  description = "The name of the IAM service role used by CodeBuild"
  value       = aws_iam_role.codebuild.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group created for CodeBuild, if created"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}
