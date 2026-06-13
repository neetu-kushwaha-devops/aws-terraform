# AWS CodeBuild Terraform Module

This Terraform module provisions an Amazon CodeBuild project with support for:
- VPC connector configuration (subnets and security groups)
- KMS-encrypted artifact storage and log configurations
- Least-privilege IAM service role with dynamic, conditional permissions for S3, ECR, CloudWatch, and VPC access
- CloudWatch log group creation with custom retention and encryption
- Dynamic environment variables and git submodules configuration

## Usage

### Basic Example (No VPC)

```hcl
module "codebuild" {
  source = "./modules/codebuild"

  name        = "my-app-builder"
  description = "Builds and tests the application"
  
  source_type = "GITHUB"
  source_location = "https://github.com/my-org/my-app.git"
  buildspec       = "buildspec.yml"

  environment_variables = [
    {
      name  = "ENV"
      value = "production"
      type  = "PLAINTEXT"
    },
    {
      name  = "API_URL"
      value = "https://api.example.com"
      type  = "PLAINTEXT"
    }
  ]

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

### Complete Example (Within VPC, pulling/pushing to ECR and S3 Artifacts)

```hcl
module "codebuild_vpc" {
  source = "./modules/codebuild"

  name         = "my-secure-builder"
  description  = "Secure builder with VPC access and ECR integrations"
  build_image  = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  compute_type = "BUILD_GENERAL1_MEDIUM"
  
  privileged_mode = true # Required for building Docker images

  source_type     = "GITHUB"
  source_location = "https://github.com/my-org/my-app.git"
  buildspec       = "buildspec-vpc.yml"

  # Artifacts stored in S3
  artifacts_type     = "S3"
  artifacts_location = "my-artifacts-s3-bucket-name"
  artifacts_path     = "builds/"
  artifacts_packaging = "ZIP"

  # VPC Configuration
  vpc_config = {
    vpc_id             = "vpc-12345678"
    subnets            = ["subnet-11111111", "subnet-22222222"]
    security_group_ids = ["sg-33333333"]
  }

  # Automatic IAM permissions generated for ECR and S3
  ecr_read_arns  = ["arn:aws:ecr:us-east-1:123456789012:repository/base-image"]
  ecr_write_arns = ["arn:aws:ecr:us-east-1:123456789012:repository/my-app"]
  s3_read_arns   = ["arn:aws:s3:::some-dependency-bucket"]

  # KMS Encryption Key for Artifacts/Logs
  encryption_key = "arn:aws:kms:us-east-1:123456789012:key/xxxx-xxxx-xxxx"

  # CloudWatch log group customization
  create_cloudwatch_log_group       = true
  cloudwatch_logs_retention_in_days = 90

  tags = {
    Environment = "production"
    Project     = "core-api"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the CodeBuild project | `string` | n/a | yes |
| `description` | A short description of the CodeBuild project | `string` | `null` | no |
| `build_timeout` | Number of minutes (5 to 480) before timing out builds | `number` | `60` | no |
| `queued_timeout` | Number of minutes (5 to 480) a build is allowed to be queued | `number` | `480` | no |
| `encryption_key` | KMS key ARN for encrypting build artifacts and logs | `string` | `null` | no |
| `build_image` | Docker image to use for the build environment | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:4.0"` | no |
| `compute_type` | Compute resource size (e.g. `BUILD_GENERAL1_SMALL`, `BUILD_GENERAL1_MEDIUM`) | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| `environment_type` | Build environment type (e.g. `LINUX_CONTAINER`, `ARM_CONTAINER`) | `string` | `"LINUX_CONTAINER"` | no |
| `privileged_mode` | Whether to enable privileged mode (for Docker-in-Docker) | `bool` | `false` | no |
| `image_pull_credentials_type` | Credentials type to pull images (`CODEBUILD` or `SERVICE_ROLE`) | `string` | `"CODEBUILD"` | no |
| `environment_variables` | List of maps of environment variables | `list(object)` | `[]` | no |
| `vpc_config` | VPC configuration object containing `vpc_id`, `subnets`, and `security_group_ids` | `object` | `null` | no |
| `source_type` | Source repository type (`CODECOMMIT`, `CODEPIPELINE`, `GITHUB`, `BITBUCKET`, `S3`, `NO_SOURCE`) | `string` | `"NO_SOURCE"` | no |
| `source_location` | Repository URL or S3 bucket path | `string` | `null` | no |
| `buildspec` | Path to buildspec file or inline buildspec content | `string` | `null` | no |
| `git_clone_depth` | Truncate depth on git clone | `number` | `null` | no |
| `git_submodules_config` | Information about git submodules configuration | `object` | `null` | no |
| `artifacts_type` | Build output artifact type (`CODEPIPELINE`, `NO_ARTIFACTS`, `S3`) | `string` | `"NO_ARTIFACTS"` | no |
| `artifacts_location` | S3 bucket name for S3 artifacts | `string` | `null` | no |
| `artifacts_path` | S3 path prefix for S3 artifacts | `string` | `null` | no |
| `artifacts_namespace_type` | Namespace organization structure (`NONE`, `BUILD_ID`) | `string` | `null` | no |
| `artifacts_packaging` | Packaging format (`NONE`, `ZIP`) | `string` | `null` | no |
| `artifacts_encryption_disabled` | Disable encrypting build output artifacts | `bool` | `false` | no |
| `cache_type` | Cache storage type (`NO_CACHE`, `LOCAL`, `S3`) | `string` | `"NO_CACHE"` | no |
| `cache_location` | S3 bucket and path for S3 cache | `string` | `null` | no |
| `cache_modes` | List of cache modes (e.g., `LOCAL_DOCKER_LAYER_CACHE`) | `list(string)` | `null` | no |
| `cloudwatch_logs_status` | Status of CloudWatch logs (`ENABLED` or `DISABLED`) | `string` | `"ENABLED"` | no |
| `cloudwatch_logs_stream_name` | CloudWatch log stream name | `string` | `null` | no |
| `s3_logs_status` | Status of S3 logs (`ENABLED` or `DISABLED`) | `string` | `"DISABLED"` | no |
| `s3_logs_location` | S3 log bucket path (`bucket-name/prefix`) | `string` | `null` | no |
| `s3_logs_encryption_disabled` | Disable S3 logs encryption | `bool` | `false` | no |
| `create_cloudwatch_log_group` | Whether to create a CloudWatch Log Group for CodeBuild | `bool` | `true` | no |
| `cloudwatch_logs_group_name` | Log group name. Defaults to `/aws/codebuild/<name>` | `string` | `null` | no |
| `cloudwatch_logs_retention_in_days` | Number of days to retain logs in CloudWatch | `number` | `30` | no |
| `cloudwatch_logs_kms_key_arn` | KMS key ARN for encrypting CloudWatch logs | `string` | `null` | no |
| `s3_read_arns` | Custom S3 bucket ARNs the project role can read | `list(string)` | `[]` | no |
| `s3_write_arns` | Custom S3 bucket ARNs the project role can write | `list(string)` | `[]` | no |
| `ecr_read_arns` | ECR repository ARNs the project role can read/pull from | `list(string)` | `[]` | no |
| `ecr_write_arns` | ECR repository ARNs the project role can write/push to | `list(string)` | `[]` | no |
| `kms_key_arns` | Additional custom KMS Key ARNs the role can use | `list(string)` | `[]` | no |
| `tags` | Map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `project_name` | The name of the CodeBuild project |
| `project_arn` | The ARN of the CodeBuild project |
| `role_arn` | The ARN of the IAM service role used by CodeBuild |
| `role_name` | The name of the IAM service role used by CodeBuild |
| `cloudwatch_log_group_arn` | The ARN of the CloudWatch log group created for CodeBuild |
