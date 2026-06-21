# AWS Service Discovery Service/Instance Terraform Module

This module registers services and instances under a Cloud Map namespace.

## Features
- Dynamic DNS configuration (records, routing policy)
- Standard and custom health checks
- Dynamic instance registration under the registered service
- Tagging support

## Usage

```hcl
module "service" {
  source       = "../service_discovery"
  name         = "web"
  namespace_id = "ns-12345678"

  dns_config = {
    routing_policy = "MULTIVALUE"
    dns_records = [{
      ttl  = 60
      type = "A"
    }]
  }

  health_check_custom_config = {
    failure_threshold = 1
  }

  instances = {
    "instance-1" = {
      attributes = {
        AWS_INSTANCE_IPV4 = "10.0.1.10"
        AWS_INSTANCE_PORT = "80"
      }
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
| name | The name of the service discovery service | string | n/a | yes |
| namespace_id | The ID of the namespace to create the service in | string | n/a | yes |
| dns_config | DNS configuration object (records, TTL, policy) | object | `null` | no |
| health_check_config | Public DNS health check config | object | `null` | no |
| health_check_custom_config | Custom/Private DNS health check config | object | `null` | no |
| instances | Map of instances to register | map(object) | `{}` | no |
| tags | Tags to assign to the resource | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| service_id | The ID of the service discovery service |
| service_arn | The ARN of the service discovery service |
| service_name | The name of the service discovery service |
| registered_instances | Map of registered instance IDs |
