# AWS Wavelength Zone Terraform Module

This module provisions AWS Wavelength resources, including carrier gateways, carrier routing tables, and subnets provisioned inside Wavelength Zones.

## Features
- Provision Carrier Gateway for mobile/carrier traffic
- Provision carrier routing table routing default traffic (`0.0.0.0/0`) via Carrier Gateway
- Subnet provisioning inside AWS Wavelength Zones
- Route Table associations
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "wavelength" {
  source = "../wavelength"
  name   = "my-5g-app"
  vpc_id = "vpc-12345678"

  subnets = {
    "boston-wl1" = {
      cidr_block        = "10.0.101.0/24"
      availability_zone = "us-east-1-wl1-bos-wlz-1"
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
| vpc_id | VPC ID to associate with resources | string | n/a | yes |
| subnets | Map of subnets to create in specific Wavelength Zones | map(object) | n/a | yes |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| carrier_gateway_id | The ID of the carrier gateway |
| carrier_gateway_arn | The ARN of the carrier gateway |
| carrier_route_table_id | The ID of the carrier route table |
| subnet_ids | Map of Wavelength subnet IDs |
| subnet_arns | Map of Wavelength subnet ARNs |
