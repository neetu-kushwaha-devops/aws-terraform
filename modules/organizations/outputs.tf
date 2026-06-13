output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = local.org_id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = local.org_arn
}

output "root_id" {
  description = "The Root ID of the AWS Organization"
  value       = local.root_id
}

output "organizational_units" {
  description = "A map of created Organizational Units with their details"
  value = {
    for k, v in aws_organizations_organizational_unit.this : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "accounts" {
  description = "A map of created member accounts with their details"
  value = {
    for k, v in aws_organizations_account.this : k => {
      id    = v.id
      arn   = v.arn
      name  = v.name
      email = v.email
    }
  }
}

output "custom_policies" {
  description = "A map of custom Service Control Policies with their details"
  value = {
    for k, v in aws_organizations_policy.custom : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}
