# AWS Config Terraform Module

This module provisions AWS Config resources, including the configuration recorder, delivery channel, S3 bucket integration, and AWS managed config rules (such as `encrypted-volumes` and `root-account-mfa`).

## Features

- **Configuration Recorder**: Records resource configurations for all supported regional resources and global resources (IAM).
- **Delivery Channel**: Delivers configuration snapshots and history to a designated S3 bucket.
- **IAM Service Role**: Optionally creates the IAM service role with standard policies and custom S3 access required by AWS Config.
- **Built-in & Custom Rules**: Automatically provisions best-practice managed rules (`encrypted-volumes`, `root-account-mfa`) and accepts user-defined managed rules with parameter configurations.

## Usage

### Standard Configuration

```hcl
module "aws_config" {
  source = "./modules/config"

  recorder_name      = "production-config"
  delivery_s3_bucket = "my-company-security-config-bucket"
  
  enable_encrypted_volumes_rule = true
  enable_root_account_mfa_rule  = true

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

### Advanced Configuration with Custom Rules

```hcl
module "aws_config_advanced" {
  source = "./modules/config"

  recorder_name          = "advanced-config"
  delivery_s3_bucket     = "my-company-security-config-bucket"
  delivery_s3_key_prefix = "config-logs"
  
  enable_encrypted_volumes_rule = true
  enable_root_account_mfa_rule  = true
  
  custom_managed_rules = {
    s3_bucket_ssl_only = {
      source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
    }
    iam_password_policy = {
      source_identifier = "IAM_PASSWORD_POLICY"
      input_parameters  = jsonencode({
        RequireUppercaseCharacters = "true"
        RequireLowercaseCharacters = "true"
        RequireNumbers             = "true"
        MinimumPasswordLength      = "14"
      })
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable` | Whether to enable AWS Config resources. | `bool` | `true` | no |
| `recorder_name` | The name of the AWS Config configuration recorder. | `string` | `"default"` | no |
| `recorder_is_enabled` | Whether the configuration recorder should record resource configurations. | `bool` | `true` | no |
| `recording_group_all_supported` | Records configurations for every supported regional resource. | `bool` | `true` | no |
| `recording_group_include_global_resource_types` | Includes global resources like IAM in recording. | `bool` | `true` | no |
| `create_iam_role` | Whether to create a new IAM role for AWS Config. | `bool` | `true` | no |
| `iam_role_name` | Name of IAM role to create (auto-generated if null). | `string` | `null` | no |
| `iam_role_arn` | Existing IAM role ARN to use (ignored if `create_iam_role` is true). | `string` | `null` | no |
| `delivery_channel_name` | The name of the AWS Config delivery channel. | `string` | `"default"` | no |
| `delivery_s3_bucket` | S3 bucket name to receive AWS Config history/snapshots. | `string` | `null` | no |
| `delivery_s3_key_prefix` | S3 key prefix for storing Config history. | `string` | `null` | no |
| `snapshot_delivery_frequency` | Frequency of configuration snapshot delivery. | `string` | `"TwentyFour_Hours"` | no |
| `enable_encrypted_volumes_rule` | Whether to enable AWS managed `encrypted-volumes` rule. | `bool` | `true` | no |
| `enable_root_account_mfa_rule` | Whether to enable AWS managed `root-account-mfa` rule. | `bool` | `true` | no |
| `custom_managed_rules` | Map of custom managed rules. Keys are names, values are rule definitions. | `map(any)` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `config_recorder_id` | The ID of the configuration recorder. |
| `config_recorder_role_arn` | The ARN of the IAM role used by the configuration recorder. |
| `config_delivery_channel_id` | The ID of the configuration delivery channel. |
| `encrypted_volumes_rule_arn` | The ARN of the encrypted-volumes rule. |
| `root_account_mfa_rule_arn` | The ARN of the root-account-mfa rule. |
| `custom_managed_rules_arns` | A map of custom managed rules to their ARNs. |
