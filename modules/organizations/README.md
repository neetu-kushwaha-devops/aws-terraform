# AWS Organizations Terraform Module

This module manages AWS Organizations resources, including organization creation (or referencing an existing organization), organizational unit (OU) structure creation, sandbox/development/production member account provisioning, and Service Control Policies (SCPs) creation and attachments.

## Features

- **Organization Provisioning**: Setup AWS Organization with custom service access principals and enabled policy types.
- **OU Structure**: Setup custom OU hierarchies (like Sandbox, Development, Production).
- **Multi-Account Setup**: Provision Sandbox, Development, and Production accounts within the desired OU.
- **Service Control Policies (SCPs)**:
  - Built-in best-practice policies:
    - **Deny Root User Access**: Restricts the usage of root credentials in member accounts.
    - **Prevent Leaving Org**: Disallows member accounts from removing themselves from the organization.
    - **Region Restriction**: Denies operations outside of approved AWS regions (excluding global services).
  - Custom SCPs: Define custom JSON policies and assign them to the Root, OUs, or specific accounts.

## Usage Example

```hcl
module "organizations" {
  source = "./modules/organizations"

  organization_name   = "my-enterprise-org"
  create_organization = true

  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]

  # Enable built-in SCPs
  enable_deny_root_scp          = true
  deny_root_scp_targets         = ["sandbox", "dev", "prod"]

  enable_prevent_leave_org_scp  = true
  prevent_leave_org_scp_targets = ["sandbox", "dev", "prod"]

  enable_region_restriction_scp = true
  allowed_regions               = ["us-east-1", "us-west-2"]
  restrict_regions_scp_targets  = ["dev", "prod"]

  # Define OUs
  organizational_units = {
    sandbox    = { name = "Sandbox" }
    dev        = { name = "Development" }
    prod       = { name = "Production" }
    security   = { name = "Security" }
  }

  # Provision Accounts
  accounts = {
    sandbox_account = {
      name                       = "sandbox-env"
      email                      = "aws-sandbox@mycorp.com"
      ou_key                     = "sandbox"
      iam_user_access_to_billing = "ALLOW"
    }
    dev_account = {
      name                       = "dev-env"
      email                      = "aws-dev@mycorp.com"
      ou_key                     = "dev"
      iam_user_access_to_billing = "ALLOW"
    }
    prod_account = {
      name                       = "prod-env"
      email                      = "aws-prod@mycorp.com"
      ou_key                     = "prod"
      iam_user_access_to_billing = "DENY"
    }
  }

  # Custom SCPs
  service_control_policies = {
    deny_delete_cloudtrail = {
      name        = "DenyDeleteCloudTrail"
      description = "Prevent member accounts from deleting or stopping CloudTrail logs"
      content     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDeleteCloudTrail",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    }
  ]
}
EOF
    }
  }

  custom_policy_attachments = {
    attach_cloudtrail_to_prod = {
      policy_key = "deny_delete_cloudtrail"
      target_key = "prod" # Attach to prod OU
    }
  }

  tags = {
    Environment = "Management"
    Project     = "LandingZone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `organization_name` | The name of the organization (used primarily for tagging/documentation) | `string` | n/a | yes |
| `create_organization` | Whether to create the AWS Organization. If false, references an existing one | `bool` | `true` | no |
| `feature_set` | Feature set of the organization (`ALL` or `CONSOLIDATED_BILLING`) | `string` | `"ALL"` | no |
| `aws_service_access_principals` | List of AWS service principal names to enable integration with | `list(string)` | `[]` | no |
| `enabled_policy_types` | List of Organizations policy types to enable | `list(string)` | `["SERVICE_CONTROL_POLICY"]` | no |
| `organizational_units` | Map of Organizational Units to create | `map(object)` | See code | no |
| `accounts` | Map of member accounts to create under the organization | `map(object)` | `{}` | no |
| `enable_deny_root_scp` | If true, creates an SCP to deny root user access in member accounts | `bool` | `false` | no |
| `deny_root_scp_targets` | List of OU keys or 'root' where the Deny Root SCP should be attached | `list(string)` | `[]` | no |
| `enable_prevent_leave_org_scp` | If true, creates an SCP to prevent member accounts from leaving the organization | `bool` | `false` | no |
| `prevent_leave_org_scp_targets` | List of OU keys or 'root' where the Prevent Leave Org SCP should be attached | `list(string)` | `[]` | no |
| `enable_region_restriction_scp` | If true, creates an SCP to restrict operations to approved AWS regions | `bool` | `false` | no |
| `allowed_regions` | List of AWS regions allowed under the region restriction SCP | `list(string)` | `["us-east-1", "us-west-2"]` | no |
| `restrict_regions_scp_targets` | List of OU keys or 'root' where the Restrict Regions SCP should be attached | `list(string)` | `[]` | no |
| `service_control_policies` | Map of custom Service Control Policies (SCPs) to create | `map(object)` | `{}` | no |
| `custom_policy_attachments` | Map of custom policy attachments | `map(object)` | `{}` | no |
| `tags` | A map of tags to assign to resources that support tagging | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `organization_id` | The ID of the AWS Organization |
| `organization_arn` | The ARN of the AWS Organization |
| `root_id` | The Root ID of the AWS Organization |
| `organizational_units` | A map of created Organizational Units with their details |
| `accounts` | A map of created member accounts with their details |
| `custom_policies` | A map of custom Service Control Policies with their details |
