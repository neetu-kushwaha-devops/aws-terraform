# VPN Gateway Module

This Terraform module provisions an AWS Virtual Private Gateway (VGW), Customer Gateways, VPN Connections (BGP or Static routing), custom IPSec tunnel parameters, static routes for VPN, and route propagation in VPC route tables.

## Features
- Create Virtual Private Gateway (VGW) and attach it to a VPC.
- Create multiple Customer Gateways (CGW).
- Create Site-to-Site VPN Connections supporting either VGW or Transit Gateway (TGW).
- Support BGP or static routing (with configurable static route destinations).
- Custom IPSec tunnel configuration options (Pre-Shared Keys, Inside CIDRs, IKE versions, DPD timeout action).
- Enable route propagation automatically for specified route tables.

## Usage Example

```hcl
module "vpn" {
  source = "./modules/vpn_gateway"

  name            = "corporate-vpn"
  vpc_id          = "vpc-0123456789abcdef0"
  amazon_side_asn = 64512

  customer_gateways = {
    office_primary = {
      bgp_asn    = 65001
      ip_address = "203.0.113.10"
      tags       = { Site = "Office-Primary" }
    }
  }

  vpn_connections = {
    corp_vpn = {
      customer_gateway_key = "office_primary"
      static_routes_only   = true
      static_routes        = ["192.168.10.0/24", "192.168.20.0/24"]
      tags                 = { Environment = "Production" }
    }
  }

  route_table_ids = [
    "rtb-0123456789abcdef0",
    "rtb-0987654321fedcba0"
  ]

  tags = {
    Project   = "mlops"
    Terraform = "true"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `create_vpn_gateway` | Whether to create the Virtual Private Gateway (VGW) | `bool` | `true` | no |
| `name` | Name to be associated with the VPN Gateway and other resources | `string` | n/a | yes |
| `vpc_id` | The ID of the VPC to attach the VPN Gateway to | `string` | `null` | no |
| `amazon_side_asn` | The Autonomous System Number (ASN) for the Amazon side of the gateway | `number` | `null` | no |
| `customer_gateways` | Map of customer gateways to create | `map(object)` | `{}` | no |
| `vpn_connections` | Map of VPN connections to create | `map(object)` | `{}` | no |
| `route_table_ids` | List of Route Table IDs in the VPC where route propagation should be enabled | `list(string)` | `[]` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpn_gateway_id` | The ID of the VPN Gateway |
| `vpn_gateway_arn` | The ARN of the VPN Gateway |
| `customer_gateway_ids` | A map of customer gateway IDs key-value pairs |
| `vpn_connection_ids` | A map of VPN connection IDs key-value pairs |
| `vpn_connection_tunnel1_address` | A map of the first tunnel public IP addresses for the VPN connections |
| `vpn_connection_tunnel2_address` | A map of the second tunnel public IP addresses for the VPN connections |
