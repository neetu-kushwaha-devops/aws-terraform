# AWS App Mesh Terraform Module

This module provisions an AWS App Mesh service mesh with virtual nodes, virtual routers, routes, and virtual services.

## Features
- Egress filtering rules
- Reusable virtual node templates
- Reusable virtual router and routing configurations (HTTP split/weight traffic routing)
- Virtual service registrations mapping nodes or routers
- Name tagging alignment

## Usage

```hcl
module "app_mesh" {
  source = "../app_mesh"
  name   = "my-app-mesh"

  virtual_nodes = {
    "web-node" = {
      backends                       = ["api-svc.local"]
      service_discovery_dns_hostname = "web.local"
      listeners = [{
        port     = 80
        protocol = "http"
      }]
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
| name | The name of the service mesh | string | n/a | yes |
| egress_filter_type | Egress filter type (`ALLOW_ALL` or `DROP_ALL`) | string | `ALLOW_ALL` | no |
| virtual_nodes | Map of virtual nodes | map(object) | `{}` | no |
| virtual_routers | Map of virtual routers | map(object) | `{}` | no |
| routes | Map of routes | map(object) | `{}` | no |
| virtual_services | Map of virtual services | map(object) | `{}` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| mesh_id | The ID of the service mesh |
| mesh_arn | The ARN of the service mesh |
| virtual_node_ids | Map of virtual node IDs |
| virtual_router_ids | Map of virtual router IDs |
| virtual_service_ids | Map of virtual service IDs |
