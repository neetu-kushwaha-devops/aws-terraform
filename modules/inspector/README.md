# AWS Inspector v2 Terraform Module

This module enables and configures Amazon Inspector v2 for automated vulnerability management. It supports configuring scan types for EC2 instances, ECR container registries, Lambda functions, and Lambda code.

## Features

- **Inspector v2 Enablement**: Automates enabling Inspector v2 across the AWS account.
- **Granular Scan Control**: Supports toggle controls for EC2 scanning, ECR container scanning, Lambda scanning, and Lambda code scanning.

## Usage

### Simple Configuration (All Scan Types Enabled)

```hcl
module "inspector" {
  source = "./modules/inspector"

  enabled            = true
  enable_ec2         = true
  enable_ecr         = true
  enable_lambda      = true
  enable_lambda_code = false
}
```

### Custom Scan Profiles

```hcl
module "inspector_custom" {
  source = "./modules/inspector"

  enabled            = true
  enable_ec2         = true
  enable_ecr         = true
  enable_lambda      = false
  enable_lambda_code = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enabled` | Whether to enable AWS Inspector v2. | `bool` | `true` | no |
| `enable_ec2` | Whether to enable EC2 scanning. | `bool` | `true` | no |
| `enable_ecr` | Whether to enable ECR scanning. | `bool` | `true` | no |
| `enable_lambda` | Whether to enable Lambda function scanning. | `bool` | `true` | no |
| `enable_lambda_code` | Whether to enable Lambda code scanning. | `bool` | `false` | no |
| `tags` | A mapping of tags to assign to resources (where supported). | `map(string)` | `{}` | no |
| `account_ids` | List of AWS account IDs to enable Inspector v2. If not specified, defaults to the current caller account ID. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `inspector_enabler_id` | The ID of the Inspector enabler (typically the AWS Account ID). |
| `enabled_resource_types` | The list of resource types enabled for Inspector v2 scanning. |
