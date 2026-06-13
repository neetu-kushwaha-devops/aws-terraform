output "security_hub_id" {
  description = "The ID of the Security Hub account"
  value       = try(aws_securityhub_account.this[0].id, null)
}

output "aws_foundational_subscription_arn" {
  description = "The ARN of the AWS Foundational Security Best Practices standard subscription"
  value       = try(aws_securityhub_standards_subscription.aws_foundational[0].id, null)
}

output "cis_subscription_arn" {
  description = "The ARN of the CIS AWS Foundations Benchmark standard subscription"
  value       = try(aws_securityhub_standards_subscription.cis[0].id, null)
}

output "pci_dss_subscription_arn" {
  description = "The ARN of the PCI DSS standard subscription"
  value       = try(aws_securityhub_standards_subscription.pci_dss[0].id, null)
}
