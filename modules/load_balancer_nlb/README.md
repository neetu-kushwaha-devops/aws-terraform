# Network Load Balancer (NLB) Module

This module provisions an AWS Network Load Balancer (NLB). It supports public or private (internal) load balancer deployments, cross-zone load balancing, dynamic subnet mapping (including static private IP mapping and Elastic IP allocation mappings), and dynamic listener rules for TCP, UDP, TCP_UDP, and TLS protocols.

## Features
- Network Load Balancer provisioning (internal or external).
- Cross-zone load balancing.
- Subnet mapping support for static/elastic IPs (EIP mapping).
- Dynamic TCP/UDP/TLS listeners creation.
- Support SSL/TLS parameters for TLS listeners (ACM certificate, SSL Policy, ALPN Policy).

## Usage Example

```hcl
module "nlb" {
  source = "../load_balancer_nlb"

  name                             = "app-nlb"
  internal                         = false
  enable_cross_zone_load_balancing = true

  # Static Elastic IP Mapping
  subnet_mappings = [
    {
      subnet_id     = "subnet-123456"
      allocation_id = "eipalloc-0123456789abcdef0"
    },
    {
      subnet_id     = "subnet-789012"
      allocation_id = "eipalloc-0123456789abcdef1"
    }
  ]

  # Dynamic TCP & TLS listeners
  listeners = [
    {
      port                     = 80
      protocol                 = "TCP"
      default_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/app-tcp-tg/12345"
    },
    {
      port                     = 443
      protocol                 = "TLS"
      ssl_policy               = "ELBSecurityPolicy-2016-08"
      certificate_arn          = "arn:aws:acm:us-east-1:123456789012:certificate/abc12345-def6-7890"
      default_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/app-tls-tg/67890"
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
| `name` | The name of the NLB | `string` | n/a | yes |
| `internal` | If true, the NLB will be internal | `bool` | `false` | no |
| `subnets` | A list of subnet IDs to associate with the NLB. Only used if `subnet_mappings` is empty | `list(string)` | `[]` | no |
| `subnet_mappings` | A list of subnet mapping blocks for mapping EIPs or private IPs | `list(object)` | `[]` | no |
| `enable_cross_zone_load_balancing` | Indicates whether cross-zone load balancing is enabled | `bool` | `true` | no |
| `enable_deletion_protection` | If true, deletion of the load balancer will be disabled | `bool` | `false` | no |
| `ip_address_type` | The type of IP addresses used by the subnets (ipv4 or dualstack) | `string` | `"ipv4"` | no |
| `listeners` | A list of listener configuration maps for TCP, UDP, TCP_UDP, and TLS protocols | `list(object)` | `[]` | no |
| `tags` | A map of tags to assign to the NLB resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `nlb_id` | The ID of the NLB |
| `nlb_arn` | The ARN of the NLB |
| `nlb_dns_name` | The DNS name of the NLB |
| `nlb_zone_id` | The canonical hosted zone ID of the load balancer |
| `listener_arns` | A map of listener protocol/port combinations to their ARNs |
