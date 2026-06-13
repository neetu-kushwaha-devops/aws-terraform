# AWS Step Functions Terraform Module

This module deploys a production-ready, highly configurable AWS Step Functions State Machine with support for:
- Amazon States Language (ASL) definition strings
- Custom IAM Execution role generation with options for additional managed policy attachments
- CloudWatch logs integration (managed inside the recommended `/aws/vendedlogs/states/` namespace)
- AWS X-Ray tracing integration
- Standard and Express State Machine workflows
- Full custom tags propagation

## Usage Example

### Standard State Machine with CloudWatch Logging and X-Ray Tracing

```hcl
module "my_state_machine" {
  source         = "./modules/step_functions"
  name           = "data-ingestion-pipeline"
  type           = "STANDARD"
  enable_xray    = true
  enable_logging = true

  definition = jsonencode({
    Comment = "A simple AWS Step Functions pipeline"
    StartAt = "Hello"
    States = {
      Hello = {
        Type = "Pass"
        Result = "Hello from Step Functions!"
        Next = "InvokeProcessing"
      }
      InvokeProcessing = {
        Type = "Task"
        Resource = "arn:aws:lambda:us-east-1:123456789012:function:data-processor"
        End = true
      }
    }
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  ]

  tags = {
    Environment = "production"
    Department  = "data-science"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Step Functions State Machine | `string` | n/a | yes |
| `definition` | The Amazon States Language (ASL) definition of the State Machine | `string` | n/a | yes |
| `type` | The type of State Machine. Valid values: STANDARD, EXPRESS | `string` | `"STANDARD"` | no |
| `create_role` | Whether to create the IAM execution role for Step Functions | `bool` | `true` | no |
| `role_arn` | The IAM execution role ARN to use if create_role is false | `string` | `null` | no |
| `policy_arns` | List of IAM policy ARNs to attach to the Step Functions execution role (only if create_role is true) | `list(string)` | `[]` | no |
| `enable_xray` | Whether to enable AWS X-Ray tracing for the State Machine | `bool` | `false` | no |
| `enable_logging` | Whether to enable CloudWatch logging for the State Machine | `bool` | `false` | no |
| `cloudwatch_logs_retention_in_days` | Specifies the number of days to retain execution log events in CloudWatch | `number` | `14` | no |
| `log_level` | Defines which category of events are logged. Valid values: ALL, ERROR, FATAL, OFF | `string` | `"ALL"` | no |
| `log_include_execution_data` | Whether to include execution data in the CloudWatch logs | `bool` | `false` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `state_machine_arn` | The ARN of the Step Functions State Machine |
| `state_machine_id` | The ID of the Step Functions State Machine |
| `state_machine_name` | The Name of the Step Functions State Machine |
| `role_arn` | The ARN of the IAM execution role |
| `role_name` | The name of the IAM execution role |
| `log_group_arn` | The ARN of the CloudWatch Log Group for execution logs |
