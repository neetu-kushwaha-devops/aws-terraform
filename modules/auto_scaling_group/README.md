# Auto Scaling Group (ASG) Module

This module provisions an AWS Auto Scaling Group (ASG) associated with a launch template. It supports configurable min/max/desired capacities, subnet zone identifiers, health check configurations, rolling instance refreshes, and target tracking scaling policies based on CPU utilization or ALB request count.

## Features
- Associated with launch templates (by ID or Name).
- Configurable capacities (`min_size`, `max_size`, `desired_capacity`).
- Health check configurations (EC2, ELB) and grace period.
- Rolling instance refresh support on launch template updates.
- Target tracking scaling policies (CPU utilization and ALB request count).
- Dynamic tagging.

## Usage Example

```hcl
module "asg" {
  source = "../auto_scaling_group"

  name                 = "web-asg"
  launch_template_id   = "lt-1234567890abcdef0"
  min_size             = 1
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = ["subnet-123456", "subnet-789012"]
  target_group_arns    = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg/1234567"]
  
  # Health Checks
  health_check_type          = "ELB"
  health_check_grace_period  = 300

  # Target Tracking Scaling Policies
  enable_cpu_scaling_policy  = true
  cpu_scaling_target_value   = 70.0

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Auto Scaling Group | `string` | n/a | yes |
| `launch_template_id` | The ID of the launch template to use | `string` | `null` | no |
| `launch_template_name` | The name of the launch template to use | `string` | `null` | no |
| `launch_template_version` | Launch template version to use | `string` | `"$Latest"` | no |
| `min_size` | The minimum size of the Auto Scaling Group | `number` | `1` | no |
| `max_size` | The maximum size of the Auto Scaling Group | `number` | `3` | no |
| `desired_capacity` | The desired capacity of the Auto Scaling Group | `number` | `1` | no |
| `vpc_zone_identifier` | A list of subnet IDs to launch resources in | `list(string)` | n/a | yes |
| `target_group_arns` | A list of target group ARNs to associate | `list(string)` | `[]` | no |
| `health_check_type` | Controls how health checking is done (EC2 or ELB) | `string` | `"EC2"` | no |
| `health_check_grace_period` | Time in seconds before checking health | `number` | `300` | no |
| `force_delete` | Allows deleting the ASG without waiting for instances to terminate | `bool` | `false` | no |
| `termination_policies` | A list of termination policies | `list(string)` | `["Default"]` | no |
| `suspended_processes` | A list of processes to suspend | `list(string)` | `[]` | no |
| `enabled_metrics` | A list of metrics to collect | `list(string)` | `[ ... ]` | no |
| `metrics_granularity` | The granularity to associate with the metrics | `string` | `"1Minute"` | no |
| `wait_for_capacity_timeout` | Maximum duration that Terraform should wait for instances to be healthy | `string` | `"10m"` | no |
| `protect_from_scale_in` | Whether new instances are protected from scale in | `bool` | `false` | no |
| `service_linked_role_arn` | The ARN of the service-linked role that the ASG will use | `string` | `null` | no |
| `max_instance_lifetime` | The maximum amount of time, in seconds, that an instance can be in service | `number` | `null` | no |
| `capacity_rebalance` | Indicates whether capacity rebalance is enabled | `bool` | `false` | no |
| `instance_refresh_strategy` | The strategy to use when replacing instances (Rolling or none) | `string` | `"Rolling"` | no |
| `instance_refresh_min_healthy_percentage` | The minimum percentage of instances that must remain healthy during refresh | `number` | `50` | no |
| `instance_refresh_triggers` | A list of triggers that will trigger an instance refresh | `list(string)` | `["launch_template"]` | no |
| `enable_cpu_scaling_policy` | Whether to enable CPU utilization target tracking scaling policy | `bool` | `false` | no |
| `cpu_scaling_target_value` | The target value for CPU utilization scaling | `number` | `70.0` | no |
| `enable_alb_request_scaling_policy` | Whether to enable ALB request count target tracking scaling policy | `bool` | `false` | no |
| `alb_request_scaling_target_value` | The target value for ALB request count scaling per target | `number` | `1000.0` | no |
| `alb_resource_label` | The resource label for the target tracking ALB scaling policy | `string` | `""` | no |
| `tags` | A map of tags to assign to the ASG resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `asg_id` | The Auto Scaling Group ID |
| `asg_arn` | The Auto Scaling Group ARN |
| `asg_name` | The Auto Scaling Group name |
| `cpu_scaling_policy_arn` | The ARN of the CPU target tracking scaling policy |
| `alb_request_scaling_policy_arn` | The ARN of the ALB request count target tracking scaling policy |
