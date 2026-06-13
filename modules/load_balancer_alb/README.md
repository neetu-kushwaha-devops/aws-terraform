# Application Load Balancer (ALB) Module

This module provisions an AWS Application Load Balancer (ALB). It supports internal or external deployments, HTTP and HTTPS listener configurations, automated HTTP-to-HTTPS redirect, SSL certificate associations (both default and additional), S3 access logging, and WAF WebACL association.

## Features
- Application Load Balancer provisioning (internal or external).
- Multi-listener setup: HTTP (Port 80) and HTTPS (Port 443).
- Optional automatic redirection from HTTP to HTTPS.
- Multiple ACM certificates support.
- S3 access logging integration.
- WAFv2 association integration.

## Usage Example

```hcl
module "alb" {
  source = "../load_balancer_alb"

  name                     = "app-alb"
  internal                 = false
  subnets                  = ["subnet-123456", "subnet-789012"]
  security_groups          = ["sg-08152345"]
  default_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/app-tg/123456"

  # HTTP/HTTPS Configuration
  http_enabled           = true
  http_redirect_to_https = true
  https_enabled          = true
  certificate_arn        = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890"

  # S3 Logging
  access_logs_enabled = true
  access_logs_bucket  = "my-alb-logs-bucket"
  access_logs_prefix  = "logs"

  # Security WAF
  waf_web_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/my-waf/abc1234"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the ALB | `string` | n/a | yes |
| `internal` | If true, the ALB will be internal | `bool` | `false` | no |
| `subnets` | A list of subnet IDs to associate with the ALB | `list(string)` | n/a | yes |
| `security_groups` | A list of security group IDs to assign to the ALB | `list(string)` | `[]` | no |
| `idle_timeout` | The time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| `enable_deletion_protection` | If true, deletion of the load balancer will be disabled | `bool` | `false` | no |
| `enable_http2` | Indicates whether HTTP/2 is enabled in the ALB | `bool` | `true` | no |
| `ip_address_type` | The type of IP addresses used by the subnets (ipv4 or dualstack) | `string` | `"ipv4"` | no |
| `access_logs_enabled` | Boolean to enable/disable access logs to S3 | `bool` | `false` | no |
| `access_logs_bucket` | The S3 bucket name to store the access logs in | `string` | `null` | no |
| `access_logs_prefix` | The S3 bucket prefix for the logs | `string` | `null` | no |
| `http_enabled` | Indicates whether HTTP (port 80) listener should be created | `bool` | `true` | no |
| `http_port` | The port for the HTTP listener | `number` | `80` | no |
| `http_redirect_to_https` | Indicates whether HTTP traffic should be redirected to HTTPS | `bool` | `false` | no |
| `https_enabled` | Indicates whether HTTPS (port 443) listener should be created | `bool` | `false` | no |
| `https_port` | The port for the HTTPS listener | `number` | `443` | no |
| `certificate_arn` | The ARN of the default SSL server certificate. Required if HTTPS is enabled | `string` | `null` | no |
| `ssl_policy` | The name of the SSL Policy for HTTPS listener | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| `default_target_group_arn` | The ARN of the default target group to forward traffic to | `string` | n/a | yes |
| `additional_certificate_arns` | A list of additional SSL certificate ARNs to attach | `list(string)` | `[]` | no |
| `waf_web_acl_arn` | The ARN of the WAFv2 WebACL to associate with the ALB | `string` | `null` | no |
| `tags` | A map of tags to assign to the ALB resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alb_id` | The ID of the ALB |
| `alb_arn` | The ARN of the ALB |
| `alb_dns_name` | The DNS name of the ALB |
| `alb_zone_id` | The canonical hosted zone ID of the load balancer |
| `http_listener_arn` | The ARN of the HTTP listener |
| `https_listener_arn` | The ARN of the HTTPS listener |
