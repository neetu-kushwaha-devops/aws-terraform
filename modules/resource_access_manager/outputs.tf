output "resource_share_id" {
  description = "The ID of the resource share"
  value       = aws_ram_resource_share.this.id
}

output "resource_share_arn" {
  description = "The ARN of the resource share"
  value       = aws_ram_resource_share.this.arn
}
