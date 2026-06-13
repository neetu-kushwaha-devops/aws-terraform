# AWS Shield Advanced Terraform Module

This module manages AWS Shield Advanced protections for critical resources such as Application Load Balancers (ALBs), Elastic IPs, CloudFront Distributions, and Route 53 hosted zones. It also supports creating Shield Advanced protection groups.

## Features

- **Shield Advanced Protection**: Protects specific resource ARNs dynamically using a friendly name map.
- **Protection Groups**: Organizes protected resources into logical groups for centralized threat detection and thresholds.

## Usage

### Shield Advanced Protection for ALB and CloudFront

```hcl
module "shield_protection" {
  source = "./modules/shield"

  enable = true
  protected_resources = {
    alb_prod        = "arn:aws:elasticloadbalancing:us-west-2:111122223333:loadbalancer/app/prod-alb/1234567890"
    cloudfront_prod = "arn:aws:cloudfront::111122223333:distribution/E1234567890ABC"
  }

  enable_protection_group      = true
  protection_group_id          = "prod-web-services"
  protection_group_aggregation = "MAX"
  protection_group_pattern     = "ARBITRARY"

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable` | Whether to enable AWS Shield Advanced protections. | `bool` | `true` | no |
| `protected_resources` | A map of resource friendly names to their resource ARNs to protect. | `map(string)` | `{}` | no |
| `enable_protection_group` | Whether to create a Shield Advanced protection group. | `bool` | `false` | no |
| `protection_group_id` | The unique identifier for the protection group. | `string` | `"global-shield-protection-group"` | no |
| `protection_group_aggregation` | How Shield combines resource data (`AVERAGE`, `MAX`, `SUM`). | `string` | `"MAX"` | no |
| `protection_group_pattern` | The pattern to choose resources (`ALL`, `ARBITRARY`, `BY_RESOURCE_TYPE`). | `string` | `"ALL"` | no |
| `protection_group_resource_type` | The resource type to include in group. Required if pattern is `BY_RESOURCE_TYPE`. | `string` | `null` | no |
| `tags` | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `protection_ids` | A map of resource names to their Shield protection IDs. |
| `protection_arns` | A map of resource names to their Shield protection ARNs. |
| `protection_group_id` | The ID of the Shield protection group. |
| `protection_group_arn` | The ARN of the Shield protection group. |
