output "pipeline_name" {
  description = "The name of the CodePipeline."
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "The Amazon Resource Name (ARN) of the CodePipeline."
  value       = aws_codepipeline.this.arn
}

output "artifact_bucket_arn" {
  description = "The ARN of the S3 artifact bucket."
  value       = aws_s3_bucket.artifacts.arn
}

output "artifact_bucket_name" {
  description = "The name of the S3 artifact bucket."
  value       = aws_s3_bucket.artifacts.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the artifact bucket."
  value       = local.kms_key_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key created by the module, or null if an existing key was provided."
  value       = var.artifact_bucket_kms_key_arn == null ? aws_kms_key.artifacts[0].key_id : null
}

output "pipeline_role_arn" {
  description = "The ARN of the IAM role used by CodePipeline."
  value       = local.pipeline_role_arn
}

output "pipeline_role_name" {
  description = "The name of the IAM role created by the module, or null if an existing role was provided."
  value       = var.create_iam_role ? aws_iam_role.pipeline[0].name : null
}

output "webhook_urls" {
  description = "A map of webhook names to their triggered URL endpoints."
  value       = { for name, webhook in aws_codepipeline_webhook.this : name => webhook.url }
}
