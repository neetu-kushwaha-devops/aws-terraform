# AWS IAM Terraform Module

This module provisions AWS IAM roles, custom policies, policy attachments, and instance profiles.

## Usage

### Simple EC2 Instance Profile Role

```hcl
module "ec2_iam_role" {
  source = "./modules/iam"

  name                    = "my-app-ec2-role"
  create_instance_profile = true

  attached_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

### Role with Custom Policy

```hcl
module "custom_iam_role" {
  source = "./modules/iam"

  name          = "my-app-custom-role"
  create_policy = true
  policy_name   = "my-app-s3-write-policy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-app-data-bucket/*"
      }
    ]
  })
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the IAM role. Also used as a base name for associated resources | `string` | n/a | yes |
| `create_role` | Whether to create the IAM role | `bool` | `true` | no |
| `assume_role_policy` | The assume role policy JSON document. If null, a default EC2 trust policy is used | `string` | `null` | no |
| `role_path` | Path of the IAM role | `string` | `"/"` | no |
| `role_description` | Description of the IAM role | `string` | `"IAM Role managed by Terraform"` | no |
| `role_permissions_boundary_arn` | Permissions boundary ARN to attach to the IAM role | `string` | `null` | no |
| `max_session_duration` | Maximum session duration (in seconds) that you want to set for the specified role | `number` | `3600` | no |
| `force_detach_policies` | Whether to force detaching any policies the role has before destroying it | `bool` | `false` | no |
| `create_policy` | Whether to create a custom IAM policy | `bool` | `false` | no |
| `policy_name` | The name of the custom IAM policy. If null, defaults to `${name}-policy` | `string` | `null` | no |
| `policy_description` | The description of the custom IAM policy | `string` | `"Custom IAM Policy managed by Terraform"` | no |
| `policy_path` | Path of the custom IAM policy | `string` | `"/"` | no |
| `policy_json` | The custom IAM policy JSON document. Required if `create_policy` is true | `string` | `null` | no |
| `attached_policy_arns` | A list of IAM policy ARNs to attach to the role | `list(string)` | `[]` | no |
| `create_instance_profile` | Whether to create an IAM instance profile | `bool` | `false` | no |
| `instance_profile_name` | Name of the instance profile. If null, defaults to the role name | `string` | `null` | no |
| `tags` | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `role_arn` | The Amazon Resource Name (ARN) specifying the role |
| `role_name` | The name of the IAM role |
| `role_unique_id` | Stable and unique string identifying the role |
| `policy_arn` | The ARN assigned by AWS to the custom policy |
| `policy_name` | The name of the custom IAM policy |
| `instance_profile_arn` | ARN assigned by AWS to the instance profile |
| `instance_profile_name` | The instance profile's name |
