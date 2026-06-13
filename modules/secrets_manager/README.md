# AWS Secrets Manager Terraform Module

This module provides a production-ready, reusable configuration to manage AWS Secrets Manager secrets. It supports creating secrets, initial secret versions, KMS encryption key specification, resource-based policies, automatic rotation, and multi-region replication.

## Features

- **Encryption**: Support for default AWS KMS keys or custom customer-managed KMS keys.
- **Resource Policies**: Attach fine-grained access policies with automatic public access blocking.
- **Versions**: Support for initial `secret_string` payload.
- **Automatic Rotation**: Integration with a rotation Lambda function via customizable schedule or duration-based rotation rules.
- **Replication**: Easily replicate secrets to other AWS regions for disaster recovery.

## Usage

### Basic Usage

```hcl
module "app_secret" {
  source = "./modules/secrets_manager"

  name          = "app/production/database-credentials"
  description   = "Database password for the production application"
  secret_string = jsonencode({
    username = "db_admin"
    password = "super-secure-random-password-12345"
  })

  tags = {
    Environment = "production"
    Team        = "database-admins"
  }
}
```

### Advanced Usage with KMS, Rotation, and Replication

```hcl
module "rotating_secret" {
  source = "./modules/secrets_manager"

  name_prefix             = "prod-api-key-"
  description             = "Third-party API credentials with rotation"
  kms_key_id              = "arn:aws:kms:us-east-1:123456789012:key/custom-key-id"
  recovery_window_in_days = 7

  secret_string = "initial-api-key-value"

  # Rotation Config
  enable_rotation     = true
  rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:secrets-rotator"
  rotation_rules = {
    automatically_after_days = 30
  }

  # Replication to another region
  replicas = [
    {
      region     = "us-west-2"
      kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/replica-key-id"
    }
  ]

  # Resource-based IAM Policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/application-lambda-role"
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The friendly name of the secret. If omitted, Terraform will generate a unique name. | `string` | `null` | no |
| `name_prefix` | Creates a unique name beginning with the specified prefix. Conflict with `name`. | `string` | `null` | no |
| `description` | A description of the secret. | `string` | `null` | no |
| `kms_key_id` | ARN or Id of the KMS key to use for encrypting the secret values. | `string` | `null` | no |
| `recovery_window_in_days` | Number of days that AWS Secrets Manager waits before permanently deleting the secret (7 to 30, or 0). | `number` | `30` | no |
| `secret_string` | Specifies text data that you want to encrypt and store in this version of the secret. | `string` | `null` | no |
| `policy` | A valid JSON document representing a resource policy. | `string` | `null` | no |
| `block_public_policy` | Makes sure that the secret cannot be accessed publicly. Only valid when `policy` is set. | `bool` | `true` | no |
| `enable_rotation` | Whether to enable automatic rotation for the secret. | `bool` | `false` | no |
| `rotation_lambda_arn` | The ARN of the Lambda function that can rotate the secret. | `string` | `null` | no |
| `rotation_rules` | A structure that defines the rotation configuration for this secret. | `object` | `null` | no |
| `replicas` | A list of replica configurations for the secret. | `list(object)` | `[]` | no |
| `tags` | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `secret_id` | The ID of the secret |
| `secret_arn` | The ARN of the secret |
| `secret_version_id` | The unique identifier of the version of the secret |
| `replica_status` | Attributes of replica status blocks |
