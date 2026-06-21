# AWS Resource Access Manager (RAM) Terraform Module

This module provisions an AWS RAM Resource Share with principal and resource association mappings.

## Features
- Create Resource Share
- Support principal mappings (AWS Accounts, Organization units, etc.)
- Support resource associations (Subnets, Transit Gateways, etc.)
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "ram" {
  source                    = "../resource_access_manager"
  name                      = "shared-subnets"
  allow_external_principals = false

  principals = [
    "arn:aws:organizations::123456789012:organization/o-exampleorg"
  ]

  resources = [
    "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-11111111"
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the resource share | string | n/a | yes |
| allow_external_principals | Allow external accounts | bool | `false` | no |
| principals | List of AWS accounts, OU, Org ARNs | list(string) | `[]` | no |
| resources | List of resource ARNs to share | list(string) | `[]` | no |
| tags | Tags to assign to resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| resource_share_id | The ID of the resource share |
| resource_share_arn | The ARN of the resource share |
