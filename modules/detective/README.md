# AWS Detective Terraform Module

This module provisions an AWS Detective behavior graph and manages invites to member accounts.

## Features
- Provision Detective behavior graph
- Invite and manage member accounts dynamically
- Support Tagging

## Usage

```hcl
module "detective" {
  source = "../detective"
  enable = true

  member_accounts = {
    "123456789012" = "secops-member1@corp.example.com"
  }

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable | Set to true to create the behavior graph | bool | `true` | no |
| member_accounts | Map of member accounts (Account ID => Email) | map(string) | `{}` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| graph_arn | The ARN of the behavior graph |
| graph_created | Creation timestamp |
