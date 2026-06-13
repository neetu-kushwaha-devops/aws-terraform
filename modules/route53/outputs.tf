output "zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = var.create_zone ? aws_route53_zone.this[0].zone_id : var.existing_zone_id
}

output "zone_arn" {
  description = "The ARN of the Route53 hosted zone"
  value       = var.create_zone ? aws_route53_zone.this[0].arn : null
}

output "name_servers" {
  description = "A list of name servers in the hosted zone (if created)"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : null
}

output "records" {
  description = "Map of created Route53 records"
  value       = aws_route53_record.this
}
