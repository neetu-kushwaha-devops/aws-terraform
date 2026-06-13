output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = aws_kms_key.this.arn
}

output "alias_arns" {
  description = "A map of alias names to their ARNs"
  value       = { for k, v in aws_kms_alias.this : v.name => v.arn }
}
