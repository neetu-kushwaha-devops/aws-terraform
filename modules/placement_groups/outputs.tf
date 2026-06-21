output "placement_group_id" {
  description = "The ID of the placement group"
  value       = aws_placement_group.this.id
}

output "placement_group_arn" {
  description = "The ARN of the placement group"
  value       = aws_placement_group.this.arn
}
