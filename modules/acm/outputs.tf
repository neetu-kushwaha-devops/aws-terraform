output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_id" {
  description = "The ID of the ACM certificate"
  value       = aws_acm_certificate.this.id
}

output "domain_validation_options" {
  description = "A list of domain validation options for the certificate"
  value       = aws_acm_certificate.this.domain_validation_options
}

output "validated_certificate_arn" {
  description = "The ARN of the validated ACM certificate (if validation is enabled, this will wait until validation is complete)"
  value       = try(aws_acm_certificate_validation.this[0].certificate_arn, aws_acm_certificate.this.arn)
}
