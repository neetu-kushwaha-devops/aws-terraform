# AWS SSM Parameter Store Terraform Module

This module provides a production-ready, reusable configuration to dynamically manage multiple AWS Systems Manager (SSM) Parameter Store parameters. It uses a `for_each` loop to create String, StringList, and SecureString parameters cleanly from a single configuration block.

## Features

- **Dynamic Parameter Creation**: Create multiple parameters using a single module call using `for_each`.
- **Supports all SSM Types**: Fully supports `String`, `StringList`, and `SecureString`.
- **KMS Integration**: Easily assign custom KMS keys to `SecureString` parameters.
- **Hierarchical Path Support**: Specify a global prefix (like `/app/production/`) to organize parameter paths.
- **Flexible Tagging**: Apply global module tags along with per-parameter tags.

## Usage

### Complete Example

```hcl
module "ssm_parameters" {
  source = "./modules/ssm_parameter_store"

  parameter_prefix = "/config/production/"

  parameters = {
    db_host = {
      type        = "String"
      value       = "db-cluster.cluster-xyz.us-east-1.rds.amazonaws.com"
      description = "Production RDS endpoint"
    }
    api_rate_limits = {
      type        = "StringList"
      value       = "100,500,1000"
      description = "Tier rate limits (free, developer, enterprise)"
    }
    db_password = {
      type        = "SecureString"
      value       = "SuperSecretDBPassword123!"
      description = "Master password for production database"
      key_id      = "arn:aws:kms:us-east-1:123456789012:key/custom-kms-key-id"
      tags = {
        SecurityLevel = "High"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Accessing Outputs in other modules

```hcl
resource "aws_instance" "app" {
  # ...
  user_data = <<-EOF
              #!/bin/bash
              echo "DB Host: ${module.ssm_parameters.parameter_names["db_host"]}"
              echo "DB Secret Parameter: ${module.ssm_parameters.parameter_arns["db_password"]}"
              EOF
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `parameter_prefix` | A prefix to apply to all parameter names (e.g. `/app/dev/`). Must end with a slash if creating hierarchical paths. | `string` | `""` | no |
| `parameters` | A map of parameters to create in SSM Parameter Store. The key is used as a suffix for the parameter name if name is not explicitly provided. | `map(object)` | `{}` | no |
| `tags` | A map of tags to apply to all SSM parameters created by this module. | `map(string)` | `{}` | no |

### `parameters` Schema

Each entry in the `parameters` map accepts the following attributes:

- `name` (optional): Override the parameter path. If omitted, the name is constructed as `${parameter_prefix}${key}`.
- `type` (required): Must be one of `String`, `StringList`, or `SecureString`.
- `value` (required): The value for the parameter.
- `description` (optional): Detailed description of the parameter.
- `tier` (optional): Parameter tier. One of `Standard`, `Advanced`, or `Intelligent-Tiering`. Defaults to `Standard`.
- `key_id` (optional): KMS key ID or ARN (used with `SecureString`).
- `allowed_pattern` (optional): Regular expression used to validate parameter values.
- `data_type` (optional): Data type for the parameter. One of `text`, `aws:ec2:image`, or `aws:ssm:integration`. Defaults to `text`.
- `tags` (optional): Map of additional tags specific to this parameter.

## Outputs

| Name | Description |
|------|-------------|
| `parameters` | A map of all created SSM parameters and their attributes (arn, name, type) |
| `parameter_names` | A map of parameter keys to parameter names |
| `parameter_arns` | A map of parameter keys to parameter ARNs |
