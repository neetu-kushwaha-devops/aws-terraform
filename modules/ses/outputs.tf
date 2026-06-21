output "domain_identity_arn" {
  description = "The ARN of the domain identity"
  value       = length(aws_ses_domain_identity.this) > 0 ? aws_ses_domain_identity.this[0].arn : null
}

output "dkim_tokens" {
  description = "The DKIM tokens for the domain"
  value       = length(aws_ses_domain_dkim.this) > 0 ? aws_ses_domain_dkim.this[0].dkim_tokens : []
}

output "email_identities" {
  description = "A map of verified individual email identities to their resource ARNs"
  value       = { for email, identity in aws_ses_email_identity.this : email => identity.arn }
}

output "active_receipt_rule_set_name" {
  description = "The name of the active receipt rule set"
  value       = length(aws_ses_active_receipt_rule_set.this) > 0 ? aws_ses_active_receipt_rule_set.this[0].rule_set_name : null
}

output "configuration_set_arn" {
  description = "The ARN of the configuration set"
  value       = length(aws_ses_configuration_set.this) > 0 ? aws_ses_configuration_set.this[0].arn : null
}

output "configuration_set_id" {
  description = "The ID of the configuration set"
  value       = length(aws_ses_configuration_set.this) > 0 ? aws_ses_configuration_set.this[0].id : null
}

output "receipt_rule_set_arn" {
  description = "The ARN of the receipt rule set"
  value       = length(aws_ses_receipt_rule_set.this) > 0 ? aws_ses_receipt_rule_set.this[0].arn : null
}
