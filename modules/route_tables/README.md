# Route Tables Module

This Terraform module creates and manages AWS Route Tables, routes, and subnet associations dynamically. It supports dynamic routes targeting various resources like Internet Gateways, NAT Gateways, Transit Gateways, VPC Endpoints, and Peering Connections.

## Features

- **Dynamic Routes**: Simplifies adding routes targeting diverse destinations.
- **Subnet Associations**: Easily map multiple subnets to each route table dynamically.
- **Unified Structure**: Manage all public and private route tables in a single module call.

## Usage

```hcl
module "route_tables" {
  source = "../modules/route_tables"
  name   = "my-app"
  vpc_id = "vpc-12345678"

  route_tables = {
    public = {
      name    = "public-rt"
      subnets = ["subnet-11111111", "subnet-22222222"]
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = "igw-87654321"
        }
      ]
    }
    private = {
      name    = "private-rt"
      subnets = ["subnet-33333333", "subnet-44444444"]
      routes = [
        {
          cidr_block     = "0.0.0.0/0"
          nat_gateway_id = "nat-99999999"
        },
        {
          cidr_block         = "10.200.0.0/16"
          transit_gateway_id = "tgw-88888888"
        }
      ]
    }
  }

  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix for the route table resources | `string` | n/a | yes |
| `vpc_id` | The VPC ID where the route tables should be created | `string` | n/a | yes |
| `route_tables` | Map of route tables config (see Usage for schema) | `map(object({...}))` | `{}` | no |
| `tags` | Common tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `route_table_ids` | Map of logical keys to Route Table IDs |
| `route_table_arns` | Map of logical keys to Route Table ARNs |
| `route_tables` | Full map of created route table resources |
| `route_table_id` | The first created Route Table ID (for backwards compatibility) |
