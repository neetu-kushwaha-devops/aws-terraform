# AWS Route53 Hosted Zone and Records Terraform Module

This module manages Amazon Route53 hosted zones (public or private) and DNS records. It supports standard DNS configurations as well as advanced routing features.

## Features

- Creates Public or Private Route53 Hosted Zones.
- Configures private zone associations with multiple VPCs.
- Supports Alias records for AWS resources (ALBs, CloudFront distributions, S3 buckets).
- Supports advanced DNS routing policies:
  - **Simple** routing
  - **Weighted** routing (with Set Identifiers)
  - **Latency-based** routing (targeting specific AWS regions)
  - **Failover** routing (Primary/Secondary records with health checks)
  - **Geolocation** routing (targeting continents, countries, or subdivisions)

## Usage Example

```hcl
module "dns" {
  source = "./modules/route53"

  zone_name    = "example.com"
  private_zone = false

  records = [
    # A standard A record
    {
      name    = "www"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.1"]
    },
    # An ALIAS record pointing to an ALB
    {
      name = "app"
      type = "A"
      alias = {
        name                   = "my-alb.us-east-1.elb.amazonaws.com"
        zone_id                = "Z35SXDOTRQ7X7K"
        evaluate_target_health = true
      }
    },
    # Weighted routing records
    {
      name           = "api"
      type           = "CNAME"
      ttl            = 60
      set_identifier = "api-v1"
      records        = ["v1.api.example.com"]
      weighted_routing_policy = {
        weight = 80
      }
    },
    {
      name           = "api"
      type           = "CNAME"
      ttl            = 60
      set_identifier = "api-v2"
      records        = ["v2.api.example.com"]
      weighted_routing_policy = {
        weight = 20
      }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `zone_name` | The name of the hosted zone | `string` | n/a | yes |
| `create_zone` | Whether to create a new Route53 hosted zone or use an existing one | `bool` | `true` | no |
| `existing_zone_id` | The ID of the existing hosted zone (required if `create_zone` is `false`) | `string` | `""` | no |
| `private_zone` | Whether the created hosted zone is a private zone associated with a VPC | `bool` | `false` | no |
| `vpc_ids` | A list of VPC IDs to associate with the private hosted zone | `list(string)` | `[]` | no |
| `vpc_regions` | A map of VPC IDs to AWS regions | `map(string)` | `{}` | no |
| `records` | List of Route53 record definitions | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to the hosted zone | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `zone_id` | The ID of the Route53 hosted zone |
| `zone_arn` | The ARN of the Route53 hosted zone (if created) |
| `name_servers` | A list of name servers in the hosted zone (if created) |
| `records` | Map of created Route53 records |
