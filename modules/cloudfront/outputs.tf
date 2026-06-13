output "distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "The domain name corresponding to the distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "The CloudFront Route53 zone ID (canonical hosted zone ID used for ALIAS records)"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_control_id" {
  description = "The ID of the Origin Access Control created for S3"
  value       = try(aws_cloudfront_origin_access_control.this[0].id, null)
}

output "origin_access_control_arn" {
  description = "The ARN of the Origin Access Control created for S3"
  value       = try(aws_cloudfront_origin_access_control.this[0].arn, null)
}
