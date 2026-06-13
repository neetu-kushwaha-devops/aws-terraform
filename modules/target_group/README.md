# Target Group Module

This module provisions an AWS Load Balancer Target Group. It supports multiple target types (instance, IP, lambda, and alb), detailed health check parameter settings, stickiness (session affinity) configurations, and dynamic attachment registration.

## Features
- Dynamic Target Group creation.
- Multiple target types supported: `instance`, `ip`, `lambda`, and `alb`.
- Customizable detailed health checks (interval, timeout, path, thresholds, protocol, matcher).
- Session stickiness support (`lb_cookie`, `app_cookie`, `source_ip`).
- Dynamic target registration (attachment of instances, IP addresses, or Lambdas).

## Usage Example

```hcl
module "target_group" {
  source = "../target_group"

  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0123456789abcdef0"
  target_type = "instance"

  # Health Checks
  health_check_path                = "/health"
  health_check_interval            = 15
  health_check_timeout             = 3
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 3
  health_check_matcher             = "200-299"

  # Stickiness (Optional)
  stickiness_enabled = true
  stickiness_type    = "lb_cookie"

  # Dynamic target attachments
  targets = [
    {
      id   = "i-0123456789abcdef0"
      port = 80
    },
    {
      id   = "i-0987654321fedcba0"
      port = 80
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the target group | `string` | n/a | yes |
| `port` | The port on which targets receive traffic | `number` | `80` | no |
| `protocol` | The protocol to use for routing traffic (HTTP, HTTPS, TCP, TLS, etc.) | `string` | `"HTTP"` | no |
| `vpc_id` | The identifier of the VPC (required unless target_type is lambda) | `string` | `null` | no |
| `target_type` | The type of target (instance, ip, lambda, or alb) | `string` | `"instance"` | no |
| `deregistration_delay` | The amount of time ELB waits before deregistering a target | `number` | `300` | no |
| `slow_start` | The amount of time during which traffic increases linearly | `number` | `0` | no |
| `load_balancing_algorithm_type` | How load balancer selects targets (round_robin, least_outstanding_requests) | `string` | `"round_robin"` | no |
| `health_check_enabled` | Indicates whether health checks are enabled | `bool` | `true` | no |
| `health_check_path` | The destination path for health check requests | `string` | `"/healthz"` | no |
| `health_check_port` | The port used when performing health checks | `string` | `"traffic-port"` | no |
| `health_check_protocol` | The protocol used for health checks (defaults to target group protocol) | `string` | `null` | no |
| `health_check_interval` | Approximate amount of time between health checks | `number` | `30` | no |
| `health_check_timeout` | Amount of time during which no response means failure | `number` | `5` | no |
| `health_check_healthy_threshold` | Consecutive successes required to consider target healthy | `number` | `3` | no |
| `health_check_unhealthy_threshold` | Consecutive failures required to consider target unhealthy | `number` | `3` | no |
| `health_check_matcher` | The HTTP codes for a successful health check response | `string` | `"200"` | no |
| `stickiness_enabled` | Indicates whether stickiness is enabled | `bool` | `false` | no |
| `stickiness_type` | The type of sticky sessions (lb_cookie, app_cookie, source_ip) | `string` | `"lb_cookie"` | no |
| `stickiness_cookie_duration` | Time period in seconds for sticky sessions | `number` | `86400` | no |
| `stickiness_cookie_name` | Name of the application cookie if stickiness_type is app_cookie | `string` | `null` | no |
| `targets` | A list of target maps to attach (keys: `id`, `port`, `availability_zone`) | `list(object)` | `[]` | no |
| `tags` | A map of tags to assign to the target group resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `target_group_id` | The ID of the target group |
| `target_group_arn` | The ARN of the target group |
| `target_group_name` | The name of the target group |
| `target_group_arn_suffix` | The ARN suffix of the target group |
| `attachments` | A map of targets attached to the target group |
