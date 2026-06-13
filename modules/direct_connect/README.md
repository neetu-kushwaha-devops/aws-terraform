# Direct Connect Module

This Terraform module provisions AWS Direct Connect connections, Direct Connect Gateways, Gateway Associations (linking to Transit Gateways or Virtual Private Gateways), and Direct Connect Virtual Interfaces (Private, Public, and Transit).

## Features
- Provision physical Direct Connect connections (e.g. at EqDC2).
- Create and manage Direct Connect Gateways (DX Gateway).
- Link Direct Connect Gateways to Transit Gateways or Virtual Private Gateways via Gateway Associations.
- Create Private Virtual Interfaces (VIFs) to establish private connectivity to a VGW or DX Gateway.
- Create Public Virtual Interfaces (VIFs) to access public AWS services via public IP spaces.
- Create Transit Virtual Interfaces (VIFs) to establish connectivity between the Direct Connect location and a Transit Gateway via a DX Gateway.

## Usage Example

```hcl
module "dx" {
  source = "./modules/direct_connect"

  name              = "my-dx-setup"
  create_connection = true
  connection_name   = "corp-dx-primary"
  bandwidth         = "1Gbps"
  location          = "EqDC2"
  provider_name     = "Equinix"

  create_dx_gateway = true
  dx_gateway_name   = "corp-dx-gateway"
  dx_gateway_asn    = 64512

  dx_gateway_associations = {
    tgw_assoc = {
      associated_gateway_id = "tgw-0123456789abcdef0"
      allowed_prefixes      = ["10.0.0.0/8"]
    }
  }

  transit_vifs = {
    transit_vif_primary = {
      name             = "dx-transit-vif"
      vlan             = 100
      address_family   = "ipv4"
      bgp_asn          = 65000
      amazon_address   = "169.254.254.1/30"
      customer_address = "169.254.254.2/30"
      bgp_auth_key     = "mysecretkey"
    }
  }

  tags = {
    Project   = "mlops"
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name for the Direct Connect resources | `string` | n/a | yes |
| `create_connection` | Whether to provision a new Direct Connect physical connection | `bool` | `false` | no |
| `connection_name` | The name of the Direct Connect connection | `string` | `null` | no |
| `bandwidth` | The bandwidth of the connection (e.g. 1Gbps, 10Gbps) | `string` | `"1Gbps"` | no |
| `location` | The Direct Connect location (e.g. EqDC2) | `string` | `null` | no |
| `provider_name` | The name of the service provider | `string` | `null` | no |
| `existing_connection_id` | Existing Direct Connect connection ID to use if not creating | `string` | `null` | no |
| `create_dx_gateway` | Whether to create a Direct Connect Gateway | `bool` | `true` | no |
| `dx_gateway_name` | The name of the Direct Connect Gateway | `string` | `null` | no |
| `dx_gateway_asn` | The ASN for the Amazon side of the Direct Connect Gateway | `number` | `64512` | no |
| `existing_dx_gateway_id` | Existing Direct Connect Gateway ID to use if not creating | `string` | `null` | no |
| `dx_gateway_associations` | Map of gateway associations (VGW or Transit Gateway) | `map(object)` | `{}` | no |
| `private_vifs` | Map of Private Virtual Interfaces (Private VIFs) | `map(object)` | `{}` | no |
| `public_vifs` | Map of Public Virtual Interfaces (Public VIFs) | `map(object)` | `{}` | no |
| `transit_vifs` | Map of Transit Virtual Interfaces (Transit VIFs) | `map(object)` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `connection_id` | The ID of the Direct Connect connection |
| `connection_arn` | The ARN of the Direct Connect connection |
| `dx_gateway_id` | The ID of the Direct Connect Gateway |
| `dx_gateway_association_ids` | A map of Direct Connect Gateway Association IDs |
| `private_vif_ids` | A map of Private Virtual Interface IDs |
| `public_vif_ids` | A map of Public Virtual Interface IDs |
| `transit_vif_ids` | A map of Transit Virtual Interface IDs |
