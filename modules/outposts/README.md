# AWS Outposts Subnet Terraform Module

This module provisions subnets and local network interfaces (LNIs) directly on an AWS Outpost rack or device.

## Features
- Provision subnet on AWS Outposts using `outpost_arn`
- Optionally associate Customer Owned IP (CoIP) pools
- Configure map CoIP on launch
- Local network interfaces (LNIs) configuration on Outposts subnet
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "outposts" {
  source                    = "../outposts"
  name                      = "my-outpost-sub"
  outpost_arn               = "arn:aws:outposts:us-east-1:123456789012:outpost/op-1234567890"
  vpc_id                    = "vpc-12345678"
  cidr_block                = "10.0.10.0/24"
  customer_owned_ipv4_pool = "ipv4pool-coip-123456"
  map_customer_owned_ip_on_launch = true

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name prefix to apply to resources | string | n/a | yes |
| outpost_arn | The ARN of the AWS Outpost | string | n/a | yes |
| vpc_id | VPC ID to associate with the subnet | string | n/a | yes |
| cidr_block | The CIDR block for the subnet | string | n/a | yes |
| customer_owned_ipv4_pool | The CoIP pool ID | string | `null` | no |
| map_customer_owned_ip_on_launch | Map CoIPs on launch | bool | `false` | no |
| network_interfaces | Map of LNIs to create | map(object) | `{}` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| subnet_id | The ID of the Outpost subnet |
| subnet_arn | The ARN of the Outpost subnet |
| network_interface_ids | Map of network interface IDs |
