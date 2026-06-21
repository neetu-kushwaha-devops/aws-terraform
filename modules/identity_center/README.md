# AWS IAM Identity Center (SSO) Terraform Module

This module provisions permission sets, manages managed/inline policies, and sets up AWS account assignments for groups/users inside AWS IAM Identity Center.

## Features
- Manage multiple custom Permission Sets
- Support inline custom IAM policy docs
- Attach multiple AWS-managed policy ARNs
- Multi-account sso user/group assignments mapping

## Usage

```hcl
module "identity_center" {
  source       = "../identity_center"
  instance_arn = "arn:aws:sso:::instance/ssoins-12345678"

  permission_sets = {
    "AdminPermissionSet" = {
      description         = "Administrator permission set"
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }

  account_assignments = [
    {
      permission_set_key = "AdminPermissionSet"
      principal_id       = "a1b2c3d4-5678"
      principal_type     = "GROUP"
      target_id          = "123456789012"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_arn | SSO / IAM Identity Center instance ARN | string | n/a | yes |
| permission_sets | Map of Permission Set configurations | map(object) | `{}` | no |
| account_assignments | Account SSO mappings | list(object) | `[]` | no |
| tags | Tags to assign to resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| permission_set_arns | Map of permission set ARNs |
| permission_set_created_details | Detailed list of permission set IDs |
