# ECR (Elastic Container Registry) Module

This Terraform module provisions an Amazon ECR repository with support for:
- KMS encryption (AWS managed or custom KMS key)
- Image scanning on push
- Registry/Repository policy attachment
- Lifecycle policies for image retention

## Usage

```hcl
module "ecr" {
  source = "./modules/ecr"

  name                 = "my-app"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "KMS"
  
  # Optional custom KMS key
  # kms_key            = "arn:aws:kms:us-east-1:123456789012:key/..."

  enable_lifecycle_policy = true
  max_image_count         = 50

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the ECR repository | `string` | n/a | yes |
| `image_tag_mutability` | Tag mutability setting (`MUTABLE` or `IMMUTABLE`) | `string` | `"MUTABLE"` | no |
| `scan_on_push` | Indicates whether images are scanned after being pushed to the repository | `bool` | `true` | no |
| `encryption_type` | The encryption type to use (`AES256` or `KMS`) | `string` | `"AES256"` | no |
| `kms_key` | The ARN of the KMS key to use when encryption_type is KMS | `string` | `null` | no |
| `repository_policy` | The JSON repository policy | `string` | `null` | no |
| `enable_lifecycle_policy` | Whether to enable the default lifecycle policy | `bool` | `true` | no |
| `max_image_count` | The maximum number of images to retain | `number` | `30` | no |
| `lifecycle_policy` | A custom JSON lifecycle policy. Overrides default if provided | `string` | `null` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `repository_arn` | Full ARN of the repository |
| `repository_url` | The URL of the repository |
| `registry_id` | The registry ID where the repository was created |
| `name` | The name of the repository |
