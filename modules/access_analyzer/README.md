# AWS Access Analyzer Terraform Module

This module provisions an AWS IAM Access Analyzer to monitor and audit resource sharing and public accessibility.

## Features
- ACCOUNT or ORGANIZATION scale boundaries configurations
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "access_analyzer" {
  source = "../access_analyzer"
  name   = "my-account-analyzer"
  type   = "ACCOUNT"

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the analyzer | string | n/a | yes |
| type | Scale boundary (`ACCOUNT` or `ORGANIZATION`) | string | `ACCOUNT` | no |
| tags | Tags to assign to resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| analyzer_id | Analyzer ID / Name |
| analyzer_arn | Analyzer ARN |
