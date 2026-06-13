# VPC Module

This module provisions an AWS VPC (Virtual Private Cloud) with DNS hostnames and resolution enabled by default. It also manages the default security group of the VPC by revoking all its ingress and egress rules to ensure a secure baseline configuration.

## Features
- Standard AWS VPC resource creation
- Optional Amazon-provided IPv6 CIDR block assignment
- Management of the VPC's default security group to block all inbound and outbound traffic
- Customizable resource tagging

## Usage Example

```hcl
module "vpc" {
  source = "../modules/vpc"

  name                 = "prod-vpc"
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_ipv6          = false

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix for the VPC resources | `string` | n/a | yes |
| `cidr_block` | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `enable_dns_hostnames` | A boolean flag to enable/disable DNS hostnames in the VPC | `bool` | `true` | no |
| `enable_dns_support` | A boolean flag to enable/disable DNS support in the VPC | `bool` | `true` | no |
| `enable_ipv6` | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix for the VPC | `bool` | `false` | no |
| `tags` | A map of tags to assign to the VPC resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `vpc_cidr_block` | The CIDR block of the VPC |
| `vpc_arn` | The ARN of the VPC |
| `default_security_group_id` | The ID of the default security group |
| `vpc_ipv6_cidr_block` | The IPv6 CIDR block assigned to the VPC |
| `vpc_ipv6_association_id` | The association ID for the IPv6 CIDR block |
