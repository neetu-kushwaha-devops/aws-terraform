# AWS KMS Terraform Module

This module provisions a Customer Managed Key (CMK) in AWS Key Management Service (KMS), supporting aliases, multi-region keys, auto-rotation, and custom key policies.

## Usage

```hcl
module "kms" {
  source = "./modules/kms"

  name                = "my-app-key"
  description         = "KMS Key for Database Encryption"
  enable_key_rotation = true
  multi_region        = false
  aliases             = ["my-app/db-key", "my-app/secondary-key"]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the KMS key. Also used as a base name for associated resources | `string` | n/a | yes |
| `description` | The description of the key as visible in Amazon Web Services console | `string` | `"KMS Customer Managed Key"` | no |
| `deletion_window_in_days` | The waiting period, specified in number of days. After the time period ends, AWS KMS deletes the KMS key | `number` | `30` | no |
| `key_usage` | Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY` | `string` | `"ENCRYPT_DECRYPT"` | no |
| `customer_master_key_spec` | Specifies whether the key contains a symmetric key or an asymmetric key pair and the algorithms supported | `string` | `"SYMMETRIC_DEFAULT"` | no |
| `is_enabled` | Specifies whether the key is enabled | `bool` | `true` | no |
| `enable_key_rotation` | Specifies whether key rotation is enabled | `bool` | `true` | no |
| `multi_region` | Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`) key | `bool` | `false` | no |
| `policy` | A valid policy JSON document. If not specified, AWS will attach a default policy | `string` | `null` | no |
| `aliases` | A list of aliases to associate with the key. Do not include 'alias/' prefix, it will be added automatically | `list(string)` | `[]` | no |
| `tags` | A map of tags to assign to the key | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `key_id` | The globally unique identifier for the key |
| `key_arn` | The Amazon Resource Name (ARN) of the key |
| `alias_arns` | A map of alias names to their ARNs |
