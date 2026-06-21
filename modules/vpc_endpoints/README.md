# AWS VPC Endpoints Terraform Module

This module provisions AWS VPC Interface and Gateway Endpoints.

## Features
- Dynamic creation of Gateway Endpoints (e.g. S3, DynamoDB) and associations with Route Tables
- Dynamic creation of Interface Endpoints (e.g. SSM, ECR, KMS) with subnets, security groups, and private DNS
- Configurable endpoint policies
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "vpc_endpoints" {
  source = "../vpc_endpoints"
  name   = "my-app"
  vpc_id = "vpc-12345678"

  gateway_endpoints = {
    s3 = {
      route_table_ids = ["rtb-12345678"]
    }
  }

  interface_endpoints = {
    ssm = {
      subnet_ids         = ["subnet-12345678"]
      security_group_ids = ["sg-12345678"]
      private_dns_enabled = true
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The prefix to apply to resource names | string | n/a | yes |
| vpc_id | The VPC ID where endpoints are created | string | n/a | yes |
| gateway_endpoints | Map of Gateway Endpoint configurations | map(object) | `{}` | no |
| interface_endpoints | Map of Interface Endpoint configurations | map(object) | `{}` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| gateway_endpoint_ids | Map of Gateway Endpoint IDs |
| interface_endpoint_ids | Map of Interface Endpoint IDs |
| interface_endpoint_dns | Map of Interface Endpoint DNS entries |
