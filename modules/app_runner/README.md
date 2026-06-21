# AWS App Runner Terraform Module

A production-ready, highly reusable Terraform module to provision AWS App Runner services. It supports both ECR image repositories and GitHub source code repositories, along with auto-scaling, custom IAM access and instance roles, private VPC networking, and KMS customer-managed key encryption.

## Features

- **Double Source Mode Support**: Seamless deployment from ECR container registries or GitHub code repositories.
- **Dynamic Tag Merging**: Enforces standard `Name` tag merged dynamically: `tags = merge({ Name = var.name }, var.tags)`.
- **Advanced Network Isolation**: Configure optional custom VPC Connectors for isolated outbound database/backend traffic.
- **Least Privilege Access Roles**: Automatically handles creation of minimal permission roles:
  - **ECR Access Role**: To authenticate and pull ECR images safely (`AWSAppRunnerServicePolicyForECR`).
  - **Instance execution Role**: To grant running container instances access to other AWS services like RDS, S3, Secrets Manager, etc.
- **Auto Scaling Control**: Create and attach custom auto-scaling configurations (concurrency, size limits).
- **Security-First defaults**: Supports custom KMS encryption keys out-of-the-box.

---

## Usage Examples

### Example 1: ECR Private Image Repository

Deploy a container image stored in a private Amazon ECR repository.

```hcl
module "app_runner_image" {
  source = "./modules/app_runner"

  name        = "my-web-app"
  source_type = "IMAGE"

  image_repository = {
    image_identifier      = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-web-app:latest"
    image_repository_type = "ECR"
    image_configuration = {
      port = "8080"
      runtime_environment_variables = {
        NODE_ENV = "production"
      }
    }
  }

  cpu    = "1024" # 1 vCPU
  memory = "2048" # 2 GB

  # VPC connection for secure, isolated outbound traffic (e.g. database access)
  create_vpc_connector = true
  vpc_subnets          = ["subnet-12345678", "subnet-87654321"]
  vpc_security_groups  = ["sg-12345678"]

  tags = {
    Environment = "production"
    Team        = "platform-eng"
  }
}
```

### Example 2: GitHub Code Repository

Deploy code directly from a private or public GitHub repository.

```hcl
module "app_runner_code" {
  source = "./modules/app_runner"

  name        = "my-node-service"
  source_type = "CODE"

  # Create a GitHub Connection
  create_connection = true
  connection_name   = "my-github-connection"

  code_repository = {
    repository_url = "https://github.com/my-org/my-node-service"
    source_code_version = {
      type  = "BRANCH"
      value = "main"
    }
    code_configuration = {
      configuration_source = "API"
      code_configuration_values = {
        runtime       = "NODEJS_16"
        build_command = "npm run build"
        start_command = "npm start"
        port          = "3000"
        runtime_environment_variables = {
          API_URL = "https://api.example.com"
        }
      }
    }
  }

  cpu    = "1024"
  memory = "2048"

  tags = {
    Environment = "staging"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the AWS App Runner service | `string` | n/a | yes |
| `source_type` | The type of the source repository. Valid values are `IMAGE` or `CODE`. | `string` | n/a | yes |
| `image_repository` | Configuration for the image repository (used if `source_type` is `IMAGE`) | `object` | `null` | no |
| `code_repository` | Configuration for the code repository (used if `source_type` is `CODE`) | `object` | `null` | no |
| `auto_deployments_enabled` | Whether to enable auto deployments on image push or code commit | `bool` | `true` | no |
| `cpu` | Reserved CPU units for each instance of your service | `string` | `"1024"` | no |
| `memory` | Reserved memory for each instance of your service | `string` | `"2048"` | no |
| `create_auto_scaling_config` | Whether to create a new auto-scaling configuration | `bool` | `false` | no |
| `auto_scaling_config_name` | Name of the auto-scaling configuration. If null, defaults to service name | `string` | `null` | no |
| `auto_scaling_max_concurrency` | Maximum concurrent requests processed by an instance before scaling | `number` | `100` | no |
| `auto_scaling_max_size` | Maximum number of instances to scale up to | `number` | `25` | no |
| `auto_scaling_min_size` | Minimum number of instances to provision | `number` | `1` | no |
| `auto_scaling_configuration_arn` | ARN of an existing auto-scaling configuration to use | `string` | `null` | no |
| `create_vpc_connector` | Whether to create a new VPC connector for outbound traffic | `bool` | `false` | no |
| `vpc_connector_name` | Name of the VPC connector. If null, defaults to service name | `string` | `null` | no |
| `vpc_subnets` | Subnet IDs in your VPC for the connector | `list(string)` | `[]` | no |
| `vpc_security_groups` | Security group IDs in your VPC for the connector | `list(string)` | `[]` | no |
| `vpc_connector_arn` | ARN of an existing VPC connector to use | `string` | `null` | no |
| `create_connection` | Whether to create a new App Runner connection for GitHub | `bool` | `false` | no |
| `connection_name` | Name of the connection | `string` | `null` | no |
| `connection_provider_type` | Source code connection provider type (only GITHUB supported) | `string` | `"GITHUB"` | no |
| `connection_arn` | ARN of an existing connection to use | `string` | `null` | no |
| `create_access_role` | Whether to create an IAM role for reading ECR private repositories | `bool` | `true` | no |
| `access_role_name` | Name of the ECR access IAM role | `string` | `null` | no |
| `access_role_arn` | ARN of an existing ECR access role to use | `string` | `null` | no |
| `create_instance_role` | Whether to create an IAM role for the application code runtime | `bool` | `true` | no |
| `instance_role_name` | Name of the instance IAM role | `string` | `null` | no |
| `instance_role_arn` | ARN of an existing instance role to use | `string` | `null` | no |
| `instance_role_policies` | Policy ARNs to attach to the instance role | `list(string)` | `[]` | no |
| `kms_key_arn` | ARN of the KMS key App Runner uses to encrypt/decrypt secrets/copy | `string` | `null` | no |
| `is_publicly_accessible` | Whether the App Runner service is publicly accessible via public URL | `bool` | `true` | no |
| `health_check_configuration` | Configuration block for health check | `object` | `null` | no |
| `tags` | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `service_id` | The unique ID of the App Runner service |
| `service_arn` | The Amazon Resource Name (ARN) of the App Runner service |
| `service_url` | The subdomain URL that App Runner associates with this service |
| `status` | The current status of the App Runner service |
| `connection_arn` | The ARN of the App Runner connection |
| `vpc_connector_arn` | The ARN of the App Runner VPC connector |
| `auto_scaling_configuration_arn` | The ARN of the App Runner auto-scaling configuration |
| `access_role_arn` | The ARN of the IAM role used by App Runner to access ECR |
| `instance_role_arn` | The ARN of the IAM role used by the App Runner instances to access other AWS services |
