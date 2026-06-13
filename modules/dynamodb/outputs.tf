output "table_id" {
  description = "The name of the table"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "The ARN of the table"
  value       = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  description = "The ARN of the Table Stream. Only available when stream_enabled = true"
  value       = aws_dynamodb_table.this.stream_arn
}

output "table_stream_label" {
  description = "A timestamp, in ISO 8601 format, for this stream"
  value       = aws_dynamodb_table.this.stream_label
}
