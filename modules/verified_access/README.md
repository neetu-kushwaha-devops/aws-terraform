# AWS Verified Access Terraform Module

This module provisions an AWS Verified Access setup, including instances, trust providers, attachment mappings, groups, and target application endpoints.

## Features
- Provision Verified Access instance
- Trust providers (OIDC or AWS IAM Identity Center) and attachment mappings
- Group permissions mapping custom policies
- Load balancer or Network interface endpoints with custom domain certificate mappings
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "verified_access" {
  source = "../verified_access"
  name   = "my-corporate-app"

  trust_providers = {
    "identity-center" = {
      policy_reference_name    = "id-center-tp"
      trust_provider_type      = "user"
      user_trust_provider_type = "iam-identity-center"
    }
  }

  groups = {
    "finance-group" = {
      description     = "Finance group policy"
      policy_document = "permit(principal, action, resource);"
    }
  }

  endpoints = {
    "finance-endpoint" = {
      group_key              = "finance-group"
      application_domain     = "finance.corp.example.com"
      endpoint_domain_prefix = "finance"
      endpoint_type          = "load-balancer"
      domain_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xyz"
      security_group_ids     = ["sg-12345678"]
      load_balancer_options = {
        load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-lb/123"
        port              = 443
        protocol          = "https"
        subnet_ids        = ["subnet-11111111", "subnet-22222222"]
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
| name | The prefix to apply to resource names | string | n/a | yes |
| description | Description for the instance | string | `null` | no |
| trust_providers | Map of trust provider configurations | map(object) | `{}` | no |
| groups | Map of verified access groups | map(object) | `{}` | no |
| endpoints | Map of target application endpoints | map(object) | `{}` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| instance_id | The ID of the Verified Access instance |
| instance_arn | The ARN of the Verified Access instance |
| trust_provider_ids | Map of trust provider IDs |
| group_ids | Map of group IDs |
| endpoint_ids | Map of endpoint IDs |
