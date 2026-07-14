# AWS ECS (Elastic Container Service) Module

This Terraform module provisions an AWS ECS cluster, associates capacity providers (Fargate, Fargate Spot, or custom EC2 providers), and optionally configures:
- ECS task definitions with support for dynamic JSON inputs
- ECS services with ALB target group associations
- Service scaling based on target tracking CPU and Memory metrics
- CloudWatch logs configuration
- Custom or default IAM roles (Task Role and Execution Role)

## Usage

### 1. Simple ECS Cluster (Fargate & Fargate Spot)

```hcl
module "ecs_cluster" {
  source = "./modules/ecs"

  name = "production-cluster"

  tags = {
    Environment = "production"
  }
}
```

### 2. Full Service Deployment (Fargate Service with Load Balancer and Autoscaling)

```hcl
module "my_service" {
  source = "./modules/ecs"

  name                   = "web-app"
  create_task_definition = true
  create_service         = true
  enable_autoscaling     = true

  # Networking
  subnets         = ["subnet-123456", "subnet-789012"]
  security_groups = ["sg-12345678"]

  # Task sizing
  task_cpu    = "256"
  task_memory = "512"

  # Container definition (dynamic JSON string)
  container_definitions = jsonencode([
    {
      name      = "web-app"
      image     = "nginx:alpine"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/web-app"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ])

  # ALB Target Group Association
  load_balancers = [
    {
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/tg-web/abcdef"
      container_name   = "web-app"
      container_port   = 80
    }
  ]

  # Autoscaling settings
  min_capacity     = 2
  max_capacity     = 10
  cpu_threshold    = 70
  memory_threshold = 80

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name to be used for the ECS cluster and as a prefix for other resources | `string` | n/a | yes |
| `cluster_settings` | Configuration block for ECS cluster settings, e.g. containerInsights | `list(map(string))` | `[{"name": "containerInsights", "value": "enabled"}]` | no |
| `fargate_capacity_providers` | List of Fargate capacity providers to associate with the cluster | `list(string)` | `["FARGATE", "FARGATE_SPOT"]` | no |
| `ec2_capacity_providers` | Map of EC2 capacity provider configurations. Key is capacity provider name | `map(object({...}))` | `{}` | no |
| `default_capacity_provider_strategy` | The default capacity provider strategy for the cluster | `list(object({...}))` | `[]` | no |
| `create_task_definition` | Whether to create an ECS task definition | `bool` | `false` | no |
| `task_family` | The family of the task definition. Defaults to `name` if null | `string` | `null` | no |
| `container_definitions` | The JSON container definitions. Required if `create_task_definition` is true | `string` | `""` | no |
| `task_definition_arn` | ARN of an existing task definition. Used if `create_service` is true and `create_task_definition` is false | `string` | `null` | no |
| `task_cpu` | The number of CPU units used by the task | `string` | `"256"` | no |
| `task_memory` | The amount of memory (in MiB) used by the task | `string` | `"512"` | no |
| `network_mode` | The network mode to use for the task definition | `string` | `"awsvpc"` | no |
| `requires_compatibilities` | A list of launch types the task requires | `list(string)` | `["FARGATE"]` | no |
| `create_execution_role` | Whether to create a default ECS task execution role | `bool` | `true` | no |
| `execution_role_arn` | ARN of an existing IAM role for task execution. Used if `create_execution_role` is false | `string` | `null` | no |
| `create_task_role` | Whether to create a default ECS task role | `bool` | `true` | no |
| `task_role_arn` | ARN of an existing IAM role for the task. Used if `create_task_role` is false | `string` | `null` | no |
| `volumes` | List of volume definitions for the task definition | `list(object({...}))` | `[]` | no |
| `create_log_group` | Whether to create a CloudWatch log group for the ECS task logs | `bool` | `true` | no |
| `log_group_retention` | Specifies the number of days you want to retain log events in the log group | `number` | `30` | no |
| `create_service` | Whether to create an ECS service | `bool` | `false` | no |
| `service_name` | The name of the service. Defaults to `name` if null | `string` | `null` | no |
| `desired_count` | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| `subnets` | Subnet IDs associated with the task or service | `list(string)` | `[]` | no |
| `security_groups` | Security groups associated with the task or service | `list(string)` | `[]` | no |
| `assign_public_ip` | Assign a public IP address to the ENI (Fargate only) | `bool` | `false` | no |
| `load_balancers` | List of load balancer configuration blocks for the service | `list(object({...}))` | `[]` | no |
| `service_registries` | List of service registry configuration blocks for the service | `list(object({...}))` | `[]` | no |
| `service_capacity_provider_strategy` | The capacity provider strategy to use for the service | `list(object({...}))` | `[]` | no |
| `deployment_minimum_healthy_percent` | The lower limit of the number of running tasks during deployment | `number` | `100` | no |
| `deployment_maximum_percent` | The upper limit of the number of running tasks during deployment | `number` | `200` | no |
| `propagate_tags` | Specifies whether to propagate the tags from the task definition or the service | `string` | `"SERVICE"` | no |
| `enable_autoscaling` | Whether to enable autoscaling for the ECS service | `bool` | `false` | no |
| `min_capacity` | The minimum number of tasks to run under autoscaling | `number` | `1` | no |
| `max_capacity` | The maximum number of tasks to run under autoscaling | `number` | `10` | no |
| `cpu_threshold` | The target CPU utilization percentage for autoscaling | `number` | `70` | no |
| `memory_threshold` | The target memory utilization percentage for autoscaling | `number` | `70` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The ID of the ECS cluster |
| `cluster_arn` | The ARN of the ECS cluster |
| `cluster_name` | The name of the ECS cluster |
| `task_definition_arn` | The ARN of the task definition |
| `task_definition_family` | The family of the task definition |
| `service_id` | The ID of the ECS service |
| `service_name` | The name of the ECS service |
| `execution_role_arn` | The ARN of the ECS task execution IAM role |
| `task_role_arn` | The ARN of the ECS task IAM role |
| `log_group_name` | The name of the CloudWatch log group |
