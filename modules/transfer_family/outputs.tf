output "server_id" {
  description = "The ID of the transfer server"
  value       = aws_transfer_server.this.id
}

output "server_arn" {
  description = "The ARN of the transfer server"
  value       = aws_transfer_server.this.arn
}

output "server_endpoint" {
  description = "The endpoint URL of the transfer server"
  value       = aws_transfer_server.this.endpoint
}

output "user_arns" {
  description = "Map of user ARNs"
  value       = { for k, v in aws_transfer_user.this : k => v.arn }
}
