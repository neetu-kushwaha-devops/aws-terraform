# AWS Global Accelerator Terraform Module

This module provisions an AWS Global Accelerator with listeners and regional endpoint groups.

## Features
- Dynamic flow logging to S3
- Listener port ranges and protocol settings
- Custom endpoint configuration supporting ALBs, NLBs, EC2 instances, and Elastic IPs
- Automatic flat mapping of listeners and regional target groups
- Name tag alignment

## Usage

```hcl
module "global_accelerator" {
  source = "../global_accelerator"
  name   = "my-accelerator"

  listeners = {
    "http-listener" = {
      port_ranges = [{
        from_port = 80
        to_port   = 80
      }]
      protocol = "TCP"
      endpoint_groups = {
        "us-east-1-group" = {
          endpoint_group_region = "us-east-1"
          endpoints = [{
            endpoint_id = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/123"
          }]
        }
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
| name | The name of the Global Accelerator | string | n/a | yes |
| ip_address_type | IP address type (`IPV4` or `DUAL_STACK`) | string | `IPV4` | no |
| enabled | Enable accelerator | bool | `true` | no |
| flow_logs_enabled | Enable flow logging to S3 | bool | `false` | no |
| flow_logs_s3_bucket | S3 bucket for flow logs | string | `null` | no |
| flow_logs_s3_prefix | S3 prefix for flow logs | string | `null` | no |
| listeners | Map of listeners and target endpoint groups | map(object) | `{}` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| accelerator_id | The ID of the accelerator |
| accelerator_arn | The ARN of the accelerator |
| dns_name | The DNS name of the accelerator |
| ip_sets | IP address sets |
| listener_ids | Map of listener IDs |
| endpoint_group_ids | Map of endpoint group IDs |
