# AWS Lambda Terraform Module

This module deploys a production-ready, highly configurable AWS Lambda function with support for:
- Zip package deployments (local or S3-sourced)
- Docker image deployments (ECR)
- Optional IAM role creation and managed policy attachments
- CloudWatch logs integration with configurable retention
- Optional VPC configuration (subnets and security groups)
- Provisioned concurrency and function aliases
- Dead Letter Queue (DLQ) support for SQS/SNS
- Optional Lambda Function URLs

## Usage Example

### Zip Deployment with VPC and Environment Variables

```hcl
module "my_lambda" {
  source      = "./modules/lambda"
  name        = "my-processing-service"
  description = "Processes incoming webhooks"
  
  package_type = "Zip"
  filename     = "path/to/my-deployment-package.zip"
  handler      = "index.handler"
  runtime      = "nodejs18.x"
  
  timeout     = 10
  memory_size = 256
  
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-87654321"]
  
  environment_variables = {
    DATABASE_URL = "postgres://username:password@endpoint:5432/db"
    NODE_ENV     = "production"
  }
  
  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

### Docker Image Deployment with Function URL

```hcl
module "my_container_lambda" {
  source      = "./modules/lambda"
  name        = "container-service"
  description = "Deploys a containerized inference service"
  
  package_type = "Image"
  image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-inference-image:latest"
  
  create_function_url    = true
  function_url_auth_type = "NONE"
  
  tags = {
    Environment = "staging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Lambda function | `string` | n/a | yes |
| `description` | A description of the Lambda function | `string` | `""` | no |
| `package_type` | The Lambda deployment package type. Valid values: Zip, Image | `string` | `"Zip"` | no |
| `handler` | The function entrypoint in the code (only for Zip package type) | `string` | `"handler.main"` | no |
| `runtime` | The Lambda runtime (only for Zip package type) | `string` | `"python3.10"` | no |
| `filename` | Path to the function's deployment package (only for Zip package type) | `string` | `null` | no |
| `s3_bucket` | S3 bucket where the deployment package is located (only for Zip package type) | `string` | `null` | no |
| `s3_key` | S3 key of the deployment package (only for Zip package type) | `string` | `null` | no |
| `s3_object_version` | S3 object version of the deployment package (only for Zip package type) | `string` | `null` | no |
| `source_code_hash` | Used to trigger updates when the file changes (only for Zip package type) | `string` | `null` | no |
| `image_uri` | The ECR image URI (only for Image package type) | `string` | `null` | no |
| `publish` | Whether to publish creation/change as a new Lambda Function Version | `bool` | `false` | no |
| `create_role` | Whether to create the IAM execution role | `bool` | `true` | no |
| `role_arn` | IAM execution role ARN to use if create_role is false | `string` | `null` | no |
| `policy_arns` | List of IAM policy ARNs to attach to the Lambda role (only if create_role is true) | `list(string)` | `[]` | no |
| `environment_variables` | Map of environment variables that are accessible from the function code | `map(string)` | `{}` | no |
| `timeout` | The amount of time your Lambda Function has to run in seconds | `number` | `3` | no |
| `memory_size` | Amount of memory in MB your Lambda Function can use at runtime | `number` | `128` | no |
| `subnet_ids` | List of VPC subnet IDs to place the Lambda function in | `list(string)` | `[]` | no |
| `security_group_ids` | List of security group IDs to associate with the Lambda function in the VPC | `list(string)` | `[]` | no |
| `dead_letter_target_arn` | The ARN of an SNS topic or SQS queue to notify when execution fails | `string` | `null` | no |
| `reserved_concurrent_executions` | The amount of reserved concurrent execution for this lambda function | `number` | `-1` | no |
| `provisioned_concurrent_executions` | The amount of provisioned concurrent execution for this lambda function | `number` | `0` | no |
| `alias_name` | Optional alias name to create pointing to the function's version | `string` | `null` | no |
| `cloudwatch_logs_retention_in_days` | Specifies the number of days you want to retain log events in the log group | `number` | `14` | no |
| `create_function_url` | Whether to create a Lambda Function URL | `bool` | `false` | no |
| `function_url_auth_type` | The authorization type for the Function URL. Valid values: NONE, AWS_IAM. | `string` | `"NONE"` | no |
| `function_url_cors` | CORS configuration for the Function URL | `object({...})` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | The name of the Lambda function |
| `arn` | The ARN of the Lambda function |
| `qualified_arn` | The qualified ARN of the Lambda function (with version/alias) |
| `version` | The published version of the Lambda function |
| `role_arn` | The ARN of the IAM execution role |
| `role_name` | The name of the IAM execution role |
| `alias_arn` | The ARN of the Lambda Function Alias |
| `function_url` | The URL of the Lambda function (if created) |
