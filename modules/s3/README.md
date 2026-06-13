# AWS S3 Bucket Terraform Module

This module provisions an AWS S3 bucket configured with security best-practices by default, including server-side encryption, versioning options, lifecycle rules, and blocking public access.

## Features

- **Server-Side Encryption**: Supports AES256 or AWS KMS customer-managed keys (SSE-KMS).
- **Public Access Block**: Enabled by default to prevent accidental data leaks.
- **Versioning**: Can be toggled on/off to preserve, retrieve, and restore every version of every object.
- **Lifecycle Configuration**: Configures automatic transitions to cheaper storage classes (like IA or Glacier) and object expiration.
- **Object Ownership**: Allows control of ownership rules (e.g., bucket-owner-enforced).

## Usage

### Simple Encrypted Private Bucket

```hcl
module "s3_bucket" {
  source = "./modules/s3"

  name               = "my-secure-application-data"
  versioning_enabled = true

  tags = {
    Environment = "production"
    Owner       = "mlops-team"
  }
}
```

### Advanced Bucket with KMS, Lifecycle Rules, and Transition to Infrequent Access

```hcl
module "s3_bucket_advanced" {
  source = "./modules/s3"

  name               = "my-advanced-data-bucket"
  bucket             = "my-advanced-data-bucket"
  versioning_enabled = true
  sse_algorithm      = "aws:kms"
  kms_master_key_id  = "arn:aws:kms:us-west-2:111122223333:key/your-custom-kms-key-id"
  bucket_key_enabled = true

  lifecycle_rules = [
    {
      id     = "archive-old-objects"
      status = "Enabled"
      filter = {
        prefix = "logs/"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
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
| `name` | The name of the S3 bucket and Name tag prefix. If bucket is not specified, this is used as the bucket name. | `string` | n/a | yes |
| `bucket` | The name of the bucket. If omitted, `var.name` is used as the bucket name. | `string` | `null` | no |
| `force_destroy` | Delete all objects from the bucket to allow deletion without error. | `bool` | `false` | no |
| `control_object_ownership` | Whether to manage S3 Bucket Ownership Controls. | `bool` | `false` | no |
| `object_ownership` | Object ownership type (e.g., `BucketOwnerEnforced`). | `string` | `"BucketOwnerEnforced"` | no |
| `acl` | Canned ACL to apply to the bucket. | `string` | `null` | no |
| `block_public_access` | Whether to block public access. Highly recommended to keep `true`. | `bool` | `true` | no |
| `versioning_enabled` | Enable or disable versioning. | `bool` | `false` | no |
| `sse_algorithm` | Server-side encryption algorithm to use (`AES256` or `aws:kms`). | `string` | `"AES256"` | no |
| `kms_master_key_id` | KMS master key ID or ARN (used with `aws:kms`). | `string` | `null` | no |
| `bucket_key_enabled` | Whether to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `false` | no |
| `lifecycle_rules` | List of lifecycle rules to configure. | `any` | `[]` | no |
| `tags` | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | The name of the bucket. |
| `bucket_arn` | The ARN of the bucket. |
| `bucket_domain_name` | The bucket domain name (bucketname.s3.amazonaws.com). |
| `bucket_regional_domain_name` | The bucket region-specific domain name. |
