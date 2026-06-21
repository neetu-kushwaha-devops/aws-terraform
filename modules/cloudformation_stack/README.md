# AWS CloudFormation Stack & StackSet Terraform Module

This module provides a production-ready, highly reusable abstraction to deploy standalone AWS CloudFormation Stacks and multi-account/multi-region AWS CloudFormation StackSets.

## Features

- **Standalone Stack Creation**: Easily provision standalone CloudFormation Stacks from template body or templates hosted on S3.
- **StackSet Support**: Provision StackSets for enterprise scale, supporting both `SELF_MANAGED` and `SERVICE_MANAGED` permission models.
- **Dynamic StackSet Instances**: Define multi-account, multi-region deployments dynamically via a list of configurations.
- **Dynamic Blocks**: Clean parameter handling, auto-deployment controls, and execution preferences.
- **Tag Merging**: Automatically applies standard naming tags and merges them with user-defined tags.

---

## Usage Examples

### 1. Standalone CloudFormation Stack (e.g., Nested Stacks)

This example shows how to deploy a parent stack that contains nested stacks. Nested stacks are typically declared in a parent template and resolved by passing the nested template S3 URL as parameters.

```hcl
module "cloudformation_stack" {
  source = "../../modules/cloudformation_stack"

  name               = "my-parent-vpc-stack"
  create_stack       = true
  create_stack_set   = false

  template_url       = "https://s3.amazonaws.com/my-templates-bucket/vpc-parent-template.yaml"
  timeout_in_minutes = 30

  parameters = {
    EnvironmentType = "Production"
    VpcCidrBlock    = "10.0.0.0/16"
    # Nested stack templates URLs passed as parameters
    SubnetTemplateUrl = "https://s3.amazonaws.com/my-templates-bucket/subnets-nested-template.yaml"
  }

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  tags = {
    Environment = "production"
    Owner       = "mlops-team"
  }
}
```

### 2. Multi-Account / Multi-Region StackSet (Self-Managed Permission Model)

This example deploys a CloudFormation StackSet across multiple AWS accounts and regions using the `SELF_MANAGED` permission model.

```hcl
module "cloudformation_stack_set_self" {
  source = "../../modules/cloudformation_stack"

  name             = "security-baseline-stackset"
  create_stack     = false
  create_stack_set = true

  template_body = <<EOF
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Deploy IAM roles for security auditing'
Resources:
  AuditRole:
    Type: 'AWS::IAM::Role'
    Properties:
      RoleName: SecurityAuditRole
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              AWS: !Sub "arn:aws:iam::$${AWS::AccountId}:root"
            Action: 'sts:AssumeRole'
EOF

  permission_model        = "SELF_MANAGED"
  administration_role_arn = "arn:aws:iam::111111111111:role/AWSCloudFormationStackSetAdministrationRole"
  execution_role_name     = "AWSCloudFormationStackSetExecutionRole"

  stack_set_deployments = [
    {
      accounts = ["222222222222", "333333333333"]
      regions  = ["us-east-1", "us-west-2"]
      parameter_overrides = {
        Environment = "prod"
      }
    }
  ]

  tags = {
    Governance = "secops"
  }
}
```

### 3. Service-Managed StackSet (AWS Organizations deployment to OUs)

This example deploys a CloudFormation StackSet targeting an AWS Organizations OU using the `SERVICE_MANAGED` permission model, allowing automatic deployment to new accounts joining the OUs.

```hcl
module "cloudformation_stack_set_org" {
  source = "../../modules/cloudformation_stack"

  name             = "config-rules-stackset"
  create_stack     = false
  create_stack_set = true

  template_url = "https://s3.amazonaws.com/my-templates-bucket/config-rules.yaml"

  permission_model = "SERVICE_MANAGED"
  
  auto_deployment = {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  stack_set_deployments = [
    {
      organizational_unit_ids = ["ou-xxxx-11111111", "ou-xxxx-22222222"]
      regions                 = ["us-east-1", "us-west-2"]
    }
  ]

  tags = {
    Automated = "true"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the CloudFormation Stack or StackSet | `string` | n/a | yes |
| `create_stack` | Whether to create a standalone CloudFormation Stack | `bool` | `true` | no |
| `create_stack_set` | Whether to create a CloudFormation StackSet | `bool` | `false` | no |
| `template_body` | Structure containing the template body (max size: 51,200 bytes) | `string` | `null` | no |
| `template_url` | Location of a file containing the template body (max size: 460,800 bytes) | `string` | `null` | no |
| `parameters` | Key-value pairs that specify input parameters for the CloudFormation template/StackSet | `map(string)` | `{}` | no |
| `capabilities` | A list of capabilities (e.g. `CAPABILITY_IAM`, `CAPABILITY_NAMED_IAM`, `CAPABILITY_AUTO_EXPAND`) | `list(string)` | `null` | no |
| `disable_rollback` | Set to true to disable rollback of the stack if stack creation failed | `bool` | `false` | no |
| `timeout_in_minutes` | The amount of time that can pass before a stack status becomes CREATE_FAILED | `number` | `null` | no |
| `iam_role_arn` | The ARN of an IAM role that AWS CloudFormation assumes to create the stack | `string` | `null` | no |
| `notification_arns` | SNS topic ARNs to publish stack related events | `list(string)` | `null` | no |
| `on_failure` | Action to be taken if stack creation fails (e.g. `DO_NOTHING`, `ROLLBACK`, `DELETE`) | `string` | `null` | no |
| `policy_body` | Structure containing the stack policy body | `string` | `null` | no |
| `policy_url` | Location of a file containing the stack policy | `string` | `null` | no |
| `description` | Description of the StackSet | `string` | `null` | no |
| `administration_role_arn` | The ARN of the IAM role that allows StackSets to manage service resources | `string` | `null` | no |
| `execution_role_name` | The name of the IAM execution role to be assumed in target accounts | `string` | `null` | no |
| `permission_model` | Permission model for StackSet (`SELF_MANAGED` or `SERVICE_MANAGED`) | `string` | `"SELF_MANAGED"` | no |
| `call_as` | Specifies whether you are acting as an administrator or a delegated administrator | `string` | `null` | no |
| `auto_deployment` | Configuration block for service-managed auto deployment behavior | `object` | `null` | no |
| `managed_execution` | Configuration block for managed execution (non-concurrent deployments) | `object` | `null` | no |
| `stack_set_deployments` | List of StackSet deployment targets and regions to deploy instances | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `stack_id` | The unique identifier of the CloudFormation Stack |
| `stack_outputs` | A map of outputs from the CloudFormation Stack |
| `stack_set_id` | The ID of the CloudFormation StackSet |
| `stack_set_arn` | The ARN of the CloudFormation StackSet |
| `stack_set_instances` | A map of stack set instances created, keyed by a generated unique key |
