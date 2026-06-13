# AWS CodeCommit Module

This Terraform module provisions an AWS CodeCommit repository with support for:
- Standard naming and repository-specific names.
- Encryption configurations using default or custom KMS Keys.
- Repository triggers mapped to SNS topics, Lambda functions, etc.
- Lambda function invocation permissions (resource-based policies) for trigger destinations.
- Custom IAM Access Policies (Read-Only, Read-Write, and Full-Access) scoped directly to the repository.
- Standard tag merging with default Name tag.

## Features

- **Encryption**: Supports AWS managed encryption or customer-managed KMS key.
- **Triggers**: Dynamic trigger blocks map the repository to notification endpoints.
- **IAM Scoping**: Option to create pre-defined customer-managed IAM policies to grant access only to the created repository following the principle of least privilege.
- **Lambda Integration**: Configures necessary resource policies on target Lambda functions so CodeCommit triggers can invoke them seamlessly.

## Usage

```hcl
module "codecommit" {
  source = "./modules/codecommit"

  name            = "my-project-repo"
  description     = "AWS CodeCommit repository for my-project application code."
  default_branch  = "main"

  # Optional encryption using custom KMS key
  # kms_key_id    = "arn:aws:kms:us-east-1:123456789012:key/..."

  # Optional Triggers Setup
  triggers = [
    {
      name            = "notify-sns"
      destination_arn = "arn:aws:sns:us-east-1:123456789012:my-notification-topic"
      events          = ["all"]
      branches        = ["main", "develop"]
    }
  ]

  # Generate IAM access policies
  create_iam_policies = true
  iam_policy_path     = "/codecommit/"

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name used for tags and naming resources | `string` | n/a | yes |
| `repository_name` | The name of the CodeCommit repository. If omitted, `var.name` will be used | `string` | `null` | no |
| `description` | The description of the CodeCommit repository | `string` | `null` | no |
| `default_branch` | The default branch of the repository. Note that the branch must already exist to be set as default | `string` | `null` | no |
| `kms_key_id` | The ARN of the KMS key to use for encrypting the repository. If not specified, the default AWS managed key `aws/codecommit` is used | `string` | `null` | no |
| `triggers` | List of repository triggers to configure | `list(object)` | `[]` | no |
| `lambda_trigger_permission_arns` | List of Lambda function names or ARNs that should be permitted to be invoked by the CodeCommit repository triggers | `list(string)` | `[]` | no |
| `create_iam_policies` | Whether to create standard IAM policies for accessing the repository | `bool` | `false` | no |
| `iam_policy_path` | Path for the generated IAM policies | `string` | `"/"` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `repository_arn` | The Amazon Resource Name (ARN) of the CodeCommit repository |
| `clone_url_http` | The URL to use for cloning the repository over HTTPS |
| `clone_url_ssh` | The URL to use for cloning the repository over SSH |
| `repository_id` | The ID of the CodeCommit repository |
| `repository_name` | The name of the CodeCommit repository |
| `read_only_policy_arn` | The ARN of the generated read-only IAM policy (if `create_iam_policies` is `true`) |
| `read_write_policy_arn` | The ARN of the generated read-write IAM policy (if `create_iam_policies` is `true`) |
| `full_access_policy_arn` | The ARN of the generated full-access IAM policy (if `create_iam_policies` is `true`) |
