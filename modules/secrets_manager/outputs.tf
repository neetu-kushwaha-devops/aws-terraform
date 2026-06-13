output "secret_id" {
  description = "The ID of the secret"
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "The ARN of the secret"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_version_id" {
  description = "The unique identifier of the version of the secret"
  value       = try(aws_secretsmanager_secret_version.this[0].version_id, null)
}

output "replica_status" {
  description = "Attributes of replica status blocks"
  value       = aws_secretsmanager_secret.this.replica
}
