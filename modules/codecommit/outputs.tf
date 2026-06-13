output "repository_arn" {
  description = "The Amazon Resource Name (ARN) of the CodeCommit repository"
  value       = aws_codecommit_repository.this.arn
}

output "clone_url_http" {
  description = "The URL to use for cloning the repository over HTTPS"
  value       = aws_codecommit_repository.this.clone_url_http
}

output "clone_url_ssh" {
  description = "The URL to use for cloning the repository over SSH"
  value       = aws_codecommit_repository.this.clone_url_ssh
}

output "repository_id" {
  description = "The ID of the CodeCommit repository"
  value       = aws_codecommit_repository.this.repository_id
}

output "repository_name" {
  description = "The name of the CodeCommit repository"
  value       = aws_codecommit_repository.this.repository_name
}

output "read_only_policy_arn" {
  description = "The ARN of the generated read-only IAM policy"
  value       = var.create_iam_policies ? aws_iam_policy.read_only[0].arn : null
}

output "read_write_policy_arn" {
  description = "The ARN of the generated read-write IAM policy"
  value       = var.create_iam_policies ? aws_iam_policy.read_write[0].arn : null
}

output "full_access_policy_arn" {
  description = "The ARN of the generated full-access IAM policy"
  value       = var.create_iam_policies ? aws_iam_policy.full_access[0].arn : null
}
