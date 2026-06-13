output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "qualified_arn" {
  description = "The qualified ARN of the Lambda function (with version/alias)"
  value       = aws_lambda_function.this.qualified_arn
}

output "version" {
  description = "The published version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "role_arn" {
  description = "The ARN of the IAM execution role"
  value       = var.create_role ? aws_iam_role.this[0].arn : var.role_arn
}

output "role_name" {
  description = "The name of the IAM execution role"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "alias_arn" {
  description = "The ARN of the Lambda Function Alias"
  value       = var.alias_name != null ? aws_lambda_alias.this[0].arn : null
}

output "function_url" {
  description = "The URL of the Lambda function (if created)"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
}
