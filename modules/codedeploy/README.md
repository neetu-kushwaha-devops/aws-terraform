# AWS CodeDeploy Terraform Module

This production-ready, highly reusable Terraform module provisions AWS CodeDeploy Applications and Deployment Groups. It supports EC2/On-Premises (`Server`), `ECS`, and `Lambda` compute platforms with clean configurations for Canary deployments, Blue/Green deployments, Auto-Rollback scenarios, Load Balancer bindings (ELB, target groups, target group pairs), and CloudWatch Alarm monitoring.

## Features

- **Multi-Platform Support**: Works seamlessly across `Server` (EC2/On-Premises), `ECS`, and `Lambda` compute platforms.
- **Flexible IAM**: Automatically creates standard IAM service roles tailored to the chosen platform (with default managed policies) or accepts pre-existing IAM roles.
- **Dynamic Blocks**: Uses Terraform dynamic blocks to cleanly support optional parameters like Blue/Green, load balancers, target group pairs, alarms, triggers, and EC2/on-premises tags.
- **Auto-Rollback & Alarms**: Integrates with CloudWatch alarms and configures auto-rollback on failure events.
- **Zero Hardcoded IDs**: Ensures complete configuration reusability with variable-driven architecture.

---

## Usage Examples

### 1. ECS Blue/Green Deployment (Canary / Linear / AllAtOnce)
This setup binds a target group pair and listener routes for an ECS Service Blue/Green deployment using the `AWSCodeDeployRoleForECS` role policy.

```hcl
module "ecs_codedeploy" {
  source = "../modules/codedeploy"

  name             = "my-ecs-app"
  compute_platform = "ECS"

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style = {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service = {
    cluster_name = "production-ecs-cluster"
    service_name = "web-service"
  }

  blue_green_deployment_config = {
    deployment_ready_option = {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
    terminate_blue_instances_on_deployment_success = {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  load_balancer_info = {
    target_group_pair_info = {
      prod_traffic_route = {
        listener_arns = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/abc123xyz789/prod-listener"]
      }
      test_traffic_route = {
        listener_arns = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/abc123xyz789/test-listener"]
      }
      target_group = [
        { name = "tg-blue" },
        { name = "tg-green" }
      ]
    }
  }

  alarm_enabled             = true
  alarm_names               = ["ecs-service-high-errors"]
  ignore_poll_alarm_failure = false

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

### 2. Lambda Canary Deployment
This configuration manages Lambda alias deployments with built-in traffic shifting configurations like `CodeDeployDefault.LambdaCanary10Percent5Minutes`.

```hcl
module "lambda_codedeploy" {
  source = "../modules/codedeploy"

  name             = "my-lambda-app"
  compute_platform = "Lambda"

  deployment_config_name = "CodeDeployDefault.LambdaCanary10Percent5Minutes"

  deployment_style = {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Service Role is created automatically with AWSCodeDeployRoleForLambda policy

  tags = {
    Environment = "staging"
  }
}
```

### 3. EC2 / Server Deployment (In-Place or Blue/Green)
Target EC2 instances using Auto Scaling Groups and load balance traffic using a classic Application Load Balancer target group.

```hcl
module "ec2_codedeploy" {
  source = "../modules/codedeploy"

  name             = "my-ec2-app"
  compute_platform = "Server"

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  deployment_style = {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  # Associate with Auto Scaling Group
  auto_scaling_groups = ["production-asg"]

  # Define ALB Target Group to block/allow traffic during deployment
  load_balancer_info = {
    target_group_info = [
      { name = "prod-ec2-target-group" }
    ]
  }

  # EC2 Filter Tags (alternative/addition to ASG mapping)
  ec2_tag_filters = [
    {
      key   = "Role"
      type  = "KEY_AND_VALUE"
      value = "web-server"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the CodeDeploy application | `string` | n/a | yes |
| `compute_platform` | The compute platform can be `Server`, `Lambda`, or `ECS` | `string` | `"Server"` | no |
| `deployment_group_name` | The name of the deployment group. Defaults to `{name}-dg` | `string` | `null` | no |
| `deployment_config_name` | The deployment configuration name (e.g. `CodeDeployDefault.OneAtATime`, `CodeDeployDefault.ECSAllAtOnce`) | `string` | `null` | no |
| `create_service_role` | Whether to create an IAM service role for CodeDeploy | `bool` | `true` | no |
| `service_role_arn` | ARN of an existing IAM role for CodeDeploy. Required if `create_service_role` is `false` | `string` | `null` | no |
| `iam_role_name` | Custom name for the IAM service role. Defaults to `{name}-codedeploy-role` | `string` | `null` | no |
| `iam_role_policy_arns` | Custom list of policy ARNs to attach to the IAM role. If empty, default managed policies are used based on `compute_platform` | `list(string)` | `[]` | no |
| `deployment_style` | Map containing deployment style options (`deployment_option` and `deployment_type`) | `map(string)` | `null` | no |
| `blue_green_deployment_config` | Map containing blue/green deployment settings (`deployment_ready_option`, `terminate_blue_instances_on_deployment_success`, `green_fleet_provisioning_option`) | `object({...})` | `null` | no |
| `load_balancer_info` | Load balancer information for the deployment group (`elb_info`, `target_group_info`, `target_group_pair_info`) | `object({...})` | `null` | no |
| `auto_rollback_enabled` | Whether auto-rollback is enabled for the deployment group | `bool` | `true` | no |
| `auto_rollback_events` | List of events that trigger auto-rollback (e.g. `DEPLOYMENT_FAILURE`) | `list(string)` | `["DEPLOYMENT_FAILURE"]` | no |
| `alarm_enabled` | Whether CloudWatch alarms are enabled for the deployment group | `bool` | `false` | no |
| `alarm_names` | List of CloudWatch alarm names to associate with the deployment group | `list(string)` | `[]` | no |
| `ignore_poll_alarm_failure` | Whether CodeDeploy should ignore poll alarm failure | `bool` | `false` | no |
| `trigger_configurations` | List of trigger configurations (events, name, target_arn) | `list(object({...}))` | `[]` | no |
| `ec2_tag_filters` | List of EC2 tag filters to select target instances for Server deployments (OR logic) | `list(object({...}))` | `[]` | no |
| `ec2_tag_sets` | List of EC2 tag sets for Server deployments (AND logic). Each set contains a list of `ec2_tag_filters` | `list(object({...}))` | `[]` | no |
| `on_premises_instance_tag_filters` | List of on-premises instance tag filters to select target instances | `list(object({...}))` | `[]` | no |
| `auto_scaling_groups` | List of Auto Scaling groups to associate with the deployment group (Server only) | `list(string)` | `[]` | no |
| `ecs_service` | Map containing `cluster_name` and `service_name` for ECS deployments | `map(string)` | `null` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `app_name` | The name of the CodeDeploy application |
| `app_id` | The ID of the CodeDeploy application |
| `deployment_group_name` | The name of the CodeDeploy deployment group |
| `deployment_group_id` | The ID of the CodeDeploy deployment group |
| `service_role_arn` | The ARN of the IAM role used by CodeDeploy |
| `service_role_name` | The name of the IAM role used by CodeDeploy |
