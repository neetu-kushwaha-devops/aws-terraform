# AWS Local Zones Subnet Terraform Module

This module provisions subnets and route table associations specifically inside AWS Local Zones (e.g., `us-west-2-lax-1a`).

## Features
- Dynamic subnet allocation inside specific AWS Local Zones
- Configurable Map Public IP on launch
- Route Table associations
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "local_zones" {
  source = "../local_zones"
  name   = "my-app"
  vpc_id = "vpc-12345678"

  subnets = {
    "lax-1a" = {
      cidr_block        = "10.0.100.0/24"
      availability_zone = "us-west-2-lax-1a"
      map_public_ip_on_launch = true
    }
  }

  route_table_id = "rtb-12345678"

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The prefix to apply to resource names | string | n/a | yes |
| vpc_id | The VPC ID where the subnets will be created | string | n/a | yes |
| subnets | Map of Local Zone subnets configurations | map(object) | n/a | yes |
| route_table_id | Route table ID to associate with the subnets | string | `null` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| subnet_ids | Map of Local Zone subnet IDs |
| subnet_arns | Map of Local Zone subnet ARNs |
