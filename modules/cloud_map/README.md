# AWS Cloud Map Namespace Terraform Module

This module provisions an AWS Cloud Map Service Discovery namespace. It supports HTTP, Private DNS, or Public DNS namespace configurations.

## Features
- HTTP Namespace support
- Private DNS Namespace support (associated with a VPC)
- Public DNS Namespace support
- Reusable clean configuration with unified output names

## Usage

```hcl
module "cloud_map" {
  source         = "../cloud_map"
  name           = "app.local"
  namespace_type = "PRIVATE_DNS"
  vpc_id         = "vpc-12345678"
  description    = "Private namespace for app services"

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the service discovery namespace | string | n/a | yes |
| namespace_type | The namespace type (`HTTP`, `PRIVATE_DNS`, or `PUBLIC_DNS`) | string | `PRIVATE_DNS` | no |
| vpc_id | VPC ID to associate with the namespace | string | `null` | no |
| description | Description for the namespace | string | `null` | no |
| tags | Tags to assign to the resource | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| namespace_id | The ID of the namespace |
| namespace_arn | The ARN of the namespace |
| namespace_name | The name of the namespace |
