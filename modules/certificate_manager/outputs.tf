output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain" {
  description = "The primary domain name of the certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "domain_validation_options" {
  description = "A list of domain validation options for the certificate, containing resource record details"
  value       = aws_acm_certificate.this.domain_validation_options
}

output "validation_records" {
  description = "A map of Route53 validation records created for DNS validation"
  value       = aws_route53_record.validation
}

output "validated_certificate_arn" {
  description = "The ARN of the validated ACM certificate (waits for validation to complete if validate_certificate is true)"
  value       = try(aws_acm_certificate_validation.this[0].certificate_arn, aws_acm_certificate.this.arn)
}
