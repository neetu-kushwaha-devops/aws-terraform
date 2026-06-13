# Transit Gateway Module

This Terraform module provisions an AWS Transit Gateway, associates multiple VPCs, creates custom Transit Gateway route tables, creates route table associations/propagations, defines static routes, and shares the Transit Gateway using AWS Resource Access Manager (RAM).

## Features
- Create Transit Gateway with configurable options (ASN, DNS, ECMP support).
- Create Transit Gateway VPC attachments.
- Create custom Transit Gateway route tables.
- Manage associations and route propagations for attachments.
- Define static routes (including blackhole routes).
- Share Transit Gateway via AWS Resource Access Manager (RAM).

## Usage Example

```hcl
module "tgw" {
  source = "./modules/transit_gateway"

  name            = "production-tgw"
  description     = "Production Transit Gateway for central hub-and-spoke networking"
  amazon_side_asn = 64512

  vpc_attachments = {
    vpc_prod = {
      vpc_id     = "vpc-0123456789abcdef0"
      subnet_ids = ["subnet-0123456789abcde01", "subnet-0123456789abcde02"]
      tags       = { Environment = "Production" }
    }
    vpc_dev = {
      vpc_id     = "vpc-0987654321fedcba0"
      subnet_ids = ["subnet-0987654321fedcb01", "subnet-0987654321fedcb02"]
      tags       = { Environment = "Development" }
    }
  }

  route_tables = {
    rt_prod = {
      name = "prod-tgw-route-table"
      tags = { Tier = "Production" }
    }
    rt_shared = {
      name = "shared-tgw-route-table"
    }
  }

  route_table_associations = {
    assoc_prod = {
      route_table_key = "rt_prod"
      attachment_key  = "vpc_prod"
    }
  }

  route_table_propagations = {
    prop_prod = {
      route_table_key = "rt_prod"
      attachment_key  = "vpc_prod"
    }
  }

  static_routes = {
    route_to_blackhole = {
      route_table_key        = "rt_prod"
      destination_cidr_block = "10.99.0.0/16"
      blackhole              = true
    }
  }

  share_tgw               = true
  ram_resource_share_name = "tgw-resource-share"
  ram_principals          = ["111122223333"] # AWS Account ID to share TGW with

  tags = {
    Project   = "mlops"
    Terraform = "true"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `create_tgw` | Whether to create the Transit Gateway | `bool` | `true` | no |
| `name` | Name to be associated with the Transit Gateway and related resources | `string` | n/a | yes |
| `description` | Description of the Transit Gateway | `string` | `"Managed by Terraform"` | no |
| `amazon_side_asn` | Private Autonomous System Number (ASN) for the Amazon side of BGP session | `number` | `64512` | no |
| `auto_accept_shared_attachments` | Automatically accept resource attachment requests | `string` | `"disable"` | no |
| `default_route_table_association` | Automatically associate attachments with default route table | `string` | `"enable"` | no |
| `default_route_table_propagation` | Automatically propagate routes to default route table | `string` | `"enable"` | no |
| `dns_support` | Enable/Disable DNS support | `string` | `"enable"` | no |
| `vpn_ecmp_support` | Enable/Disable VPN Equal Cost Multipath Protocol support | `string` | `"enable"` | no |
| `multicast_support` | Enable/Disable Multicast support | `string` | `"disable"` | no |
| `transit_gateway_cidr_blocks` | List of IPv4 or IPv6 CIDR blocks for the Transit Gateway | `list(string)` | `[]` | no |
| `vpc_attachments` | Map of VPC attachments to create | `map(object)` | `{}` | no |
| `route_tables` | Map of custom Transit Gateway route tables to create | `map(object)` | `{}` | no |
| `route_table_associations` | Map of route table associations to create | `map(object)` | `{}` | no |
| `route_table_propagations` | Map of route table propagations to create | `map(object)` | `{}` | no |
| `static_routes` | Map of static routes to create in Transit Gateway route tables | `map(object)` | `{}` | no |
| `share_tgw` | Whether to share the Transit Gateway via Resource Access Manager (RAM) | `bool` | `false` | no |
| `ram_resource_share_name` | The name of the RAM resource share. Defaults to '<name>-share' | `string` | `null` | no |
| `ram_principals` | List of AWS Account IDs, OU ARNs, or Org ARNs to share TGW with | `list(string)` | `[]` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `transit_gateway_id` | The ID of the Transit Gateway |
| `transit_gateway_arn` | The ARN of the Transit Gateway |
| `transit_gateway_owner_id` | The owner ID of the Transit Gateway |
| `transit_gateway_association_default_route_table_id` | The ID of the default association route table |
| `transit_gateway_propagation_default_route_table_id` | The ID of the default propagation route table |
| `vpc_attachment_ids` | A map of Transit Gateway VPC attachment IDs key-value pairs |
| `route_table_ids` | A map of Transit Gateway custom route table IDs key-value pairs |
| `ram_resource_share_id` | The ID of the RAM resource share |
