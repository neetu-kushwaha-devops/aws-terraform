output "firewall_id" {
  description = "The ID of the firewall"
  value       = aws_networkfirewall_firewall.this.id
}

output "firewall_arn" {
  description = "The ARN of the firewall"
  value       = aws_networkfirewall_firewall.this.arn
}

output "firewall_status" {
  description = "The status of the firewall endpoints"
  value       = aws_networkfirewall_firewall.this.firewall_status
}

output "firewall_policy_id" {
  description = "The ID of the firewall policy"
  value       = aws_networkfirewall_firewall_policy.this.id
}

output "firewall_policy_arn" {
  description = "The ARN of the firewall policy"
  value       = aws_networkfirewall_firewall_policy.this.arn
}
