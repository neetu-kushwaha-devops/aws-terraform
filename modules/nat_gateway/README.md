# NAT Gateway Module

This Terraform module creates and manages AWS NAT Gateways, supporting both single and multi-NAT gateway topologies for high availability (HA) vs cost saving environments.

## Features

- **Cost Optimization**: Set `single_nat_gateway = true` to deploy a single NAT Gateway shared across all private subnets.
- **High Availability**: Set `single_nat_gateway = false` (default) to deploy one NAT Gateway per public subnet (typically per Availability Zone).
- **Flexible EIP Management**: Automatically creates and associates Elastic IPs (default) or allows passing in existing `eip_allocation_ids`.

## Usage

### Single NAT Gateway (Cost Optimization)

```hcl
module "nat" {
  source             = "../modules/nat_gateway"
  name               = "my-app-nat"
  subnet_ids         = ["subnet-12345678"] # Pass first public subnet ID
  single_nat_gateway = true
  
  tags = {
    Environment = "dev"
  }
}
```

### Multi-NAT Gateway (High Availability)

```hcl
module "nat" {
  source             = "../modules/nat_gateway"
  name               = "my-app-nat"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"] # Multiple public subnet IDs
  single_nat_gateway = false
  
  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix for the resources | `string` | n/a | yes |
| `subnet_ids` | List of public subnet IDs where the NAT Gateways should be created | `list(string)` | n/a | yes |
| `enable_nat_gateway` | Should be true to create NAT Gateways | `bool` | `true` | no |
| `single_nat_gateway` | Should be true if you want to create a single NAT Gateway shared across all private subnets | `bool` | `false` | no |
| `create_eip` | Should be true to create Elastic IPs for the NAT Gateways. If false, `eip_allocation_ids` must be provided | `bool` | `true` | no |
| `eip_allocation_ids` | List of existing EIP allocation IDs to associate with NAT Gateways (required if `create_eip` is false) | `list(string)` | `[]` | no |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `nat_gateway_ips` | List of public IPs of the NAT Gateways |
| `eip_allocation_ids` | List of Elastic IP allocation IDs used by the NAT Gateways |
