# AWS CodePipeline Terraform Module

This production-ready, highly reusable Terraform module provisions an **AWS CodePipeline** with a secure S3 artifact store, KMS encryption, customizable IAM roles, dynamic stage/action configurations, and webhook trigger support.

## Features

- **Dynamic Stages & Actions**: Declare arbitrarily complex multi-stage pipelines with support for sequential and parallel actions, input/output artifacts, and action-level configurations.
- **KMS Encrypted Artifact Store**: Configures an S3 artifact bucket secured with a customer-managed KMS key (which can be auto-created or user-provided).
- **Hardened S3 Bucket**: Automatically blocks public access, enforces SSL/TLS requests only, enables versioning, and provides a default 30-day lifecycle expiration policy to avoid storage bloat.
- **Flexible IAM Role Configuration**: Provisions a tailored IAM service execution role with pre-configured minimum access policies, or accepts an existing role. You can also append custom IAM policy statements or attach additional policy ARNs.
- **Webhook Integration**: Support for webhooks (IP-based, GITHUB_HMAC, or UNAUTHENTICATED) to trigger pipelines on external events.
- **V2 Pipeline Support**: Supports CodePipeline V2 properties including pipeline-level trigger configurations.

## Usage

Here is a typical production example using a CodeStar Connection to pull from GitHub, a CodeBuild action to build/test, and an ECS deployment:

```hcl
module "codepipeline" {
  source = "./modules/codepipeline"

  name = "my-application-pipeline"

  # S3 bucket configuration for artifacts
  artifact_bucket_name            = "my-app-codepipeline-artifacts"
  artifact_bucket_expiration_days = 14

  stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "GitHub-Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          output_artifacts = ["source_output"]
          configuration = {
            ConnectionArn    = "arn:aws:codestar-connections:us-west-2:123456789012:connection/a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"
            FullRepositoryId = "my-organization/my-repository"
            BranchName       = "main"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build-And-Test"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName = "my-codebuild-project"
          }
        }
      ]
    },
    {
      name = "Deploy"
      actions = [
        {
          name            = "Deploy-To-ECS"
          category        = "Deploy"
          owner           = "AWS"
          provider        = "ECS"
          version         = "1"
          input_artifacts = ["build_output"]
          configuration = {
            ClusterName = "my-ecs-cluster"
            ServiceName = "my-ecs-service"
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    Team        = "DevOps"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the AWS CodePipeline. | `string` | n/a | yes |
| `stages` | A list of stage configurations. Each stage contains a name and a list of actions. | `list(object)` | n/a | yes |
| `artifact_bucket_name` | The name of the S3 bucket to store artifacts. If omitted, the bucket name will be generated using the pipeline name as a prefix. | `string` | `null` | no |
| `artifact_bucket_kms_key_arn` | The ARN of an existing KMS key to encrypt the artifact bucket. If omitted, a new customer-managed KMS key will be created. | `string` | `null` | no |
| `artifact_bucket_force_destroy` | A boolean that indicates all objects should be deleted from the artifact bucket so that the bucket can be destroyed without error. | `bool` | `false` | no |
| `artifact_bucket_expiration_days` | The number of days to keep artifacts before S3 automatically expires/deletes them. Set to null to disable expiration. | `number` | `30` | no |
| `artifact_bucket_lifecycle_rules` | A list of custom lifecycle rules to apply to the S3 artifact bucket. Overrides the default expiration rule if provided. | `list(object({...}))` | `null` | no |
| `webhooks` | A list of webhook configurations to trigger the pipeline. | `list(object)` | `[]` | no |
| `pipeline_type` | The type of the pipeline. Valid values are V1 and V2. If omitted, the default provider value is used. | `string` | `null` | no |
| `triggers` | Trigger configuration for the pipeline (supported in V2 pipelines). | `list(object({...}))` | `[]` | no |
| `create_iam_role` | Whether to create a new IAM role for CodePipeline. If false, var.iam_role_arn must be provided. | `bool` | `true` | no |
| `iam_role_arn` | The ARN of an existing IAM role to use for CodePipeline. Only used if var.create_iam_role is false. | `string` | `null` | no |
| `iam_role_name` | The name of the IAM role to create. If omitted, the name is generated using the pipeline name. | `string` | `null` | no |
| `iam_role_path` | The path for the IAM role to create. | `string` | `"/"` | no |
| `custom_iam_policy_statements` | A list of additional custom IAM policy statements to attach to the CodePipeline service role. | `list(object({...}))` | `[]` | no |
| `iam_role_policy_arns` | A list of IAM policy ARNs to attach to the CodePipeline service role. | `list(string)` | `[]` | no |
| `tags` | A mapping of tags to assign to all resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `pipeline_name` | The name of the CodePipeline. |
| `pipeline_arn` | The Amazon Resource Name (ARN) of the CodePipeline. |
| `artifact_bucket_arn` | The ARN of the S3 artifact bucket. |
| `artifact_bucket_name` | The name of the S3 artifact bucket. |
| `kms_key_arn` | The ARN of the KMS key used to encrypt the artifact bucket. |
| `kms_key_id` | The ID of the KMS key created by the module, or null if an existing key was provided. |
| `pipeline_role_arn` | The ARN of the IAM role used by CodePipeline. |
| `pipeline_role_name` | The name of the IAM role created by the module, or null if an existing role was provided. |
| `webhook_urls` | A map of webhook names to their triggered URL endpoints. |
