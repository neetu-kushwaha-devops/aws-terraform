# AWS EventBridge Terraform Module

This module deploys a production-ready, highly configurable AWS EventBridge Rule mapping with support for:
- Standard schedule expressions (cron/rate) or Event patterns
- Custom EventBus creation and targeting
- Multi-target mapping configurations
- Native automation of target execution permissions (automatically handles Lambda permissions, and dynamically creates a target execution IAM role for Step Functions and ECS targets if needed)
- Dead Letter Queue configuration support for targets
- Custom tags propagation

## Usage Examples

### Schedule Rule with Lambda Target

```hcl
module "hourly_cleaner" {
  source              = "./modules/eventbridge"
  name                = "database-hourly-cleaner"
  description         = "Triggers database cleanup lambda every hour"
  schedule_expression = "rate(1 hour)"

  targets = {
    cleanup_lambda = {
      arn = "arn:aws:lambda:us-east-1:123456789012:function:db-cleanup-task"
    }
  }

  tags = {
    Environment = "production"
    Service     = "database-admin"
  }
}
```

### Event Pattern Rule Triggering Step Functions and ECS Task (Dynamic Role Generation)

```hcl
module "data_pipeline_trigger" {
  source        = "./modules/eventbridge"
  name          = "on-s3-upload"
  description   = "Triggers pipeline state machine and container task on S3 uploads"
  create_bus    = true
  bus_name      = "mlops-events"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail_type = ["Object Created"]
    detail = {
      bucket = {
        name = ["ml-data-ingestion-bucket"]
      }
    }
  })

  targets = {
    sfn_trigger = {
      arn = "arn:aws:states:us-east-1:123456789012:stateMachine:data-ingestion-pipeline"
    }
    ecs_task_trigger = {
      arn = "arn:aws:ecs:us-east-1:123456789012:cluster/mlops-cluster"
      ecs_target = {
        task_definition_arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/data-preprocessor:2"
        subnet_ids          = ["subnet-12345678", "subnet-87654321"]
        assign_public_ip    = true
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the EventBridge Rule | `string` | n/a | yes |
| `description` | The description of the EventBridge Rule | `string` | `"EventBridge Rule managed by Terraform"` | no |
| `create_bus` | Whether to create a custom EventBus | `bool` | `false` | no |
| `bus_name` | The name of the EventBus | `string` | `"default"` | no |
| `schedule_expression` | The scheduling expression | `string` | `null` | no |
| `event_pattern` | The event pattern described a JSON object | `string` | `null` | no |
| `is_enabled` | Whether the rule should be enabled | `bool` | `true` | no |
| `create_target_role` | Whether to create an IAM role for EventBridge targets (SFN, ECS) | `bool` | `true` | no |
| `targets` | A map of targets for this rule | `map(object({...}))` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `rule_arn` | The ARN of the EventBridge Rule |
| `rule_id` | The ID/Name of the EventBridge Rule |
| `rule_name` | The Name of the EventBridge Rule |
| `bus_arn` | The ARN of the EventBridge Bus (if created) |
| `bus_name` | The Name of the EventBridge Bus used or created |
| `target_ids` | The Map of target IDs created |
| `target_role_arn` | The ARN of the generated IAM execution role for targets |
