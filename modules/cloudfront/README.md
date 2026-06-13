# AWS CloudFront Distribution Terraform Module

This module manages Amazon CloudFront distributions, supporting multiple origins (S3 buckets, ALBs, APIs), modern Origin Access Control (OAC) for secure S3 ingestion, routing/caching rules, custom SSL certificates, geo-blocking, custom error response pages, and AWS WAF integration.

## Features

- Dynamic origins: Supports both S3 buckets and custom HTTP servers (e.g. Application Load Balancers).
- S3 Origin Access Control (OAC): Automates creation and mapping of the modern OAC signing mechanism for secure S3 origins.
- Custom SSL: Connects custom alternate domain names (CNAMEs/aliases) using AWS Certificate Manager (ACM) certificates.
- Dynamic cache behaviors:
  - Supports the modern recommended policy-driven workflow (using standard AWS Managed Cache and Origin Request Policies).
  - Falls back to legacy query string/cookie/header forward structures if cache policy is not used.
- Geo restrictions (whitelist or blacklist).
- Custom error pages (maps HTTP response codes to friendly error landing pages).
- Integrates with regional or global Web ACLs (WAFv2).

## Usage Example

```hcl
module "cloudfront" {
  source = "./modules/cloudfront"

  name    = "my-web-app"
  aliases = ["www.example.com", "example.com"]

  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"

  origins = [
    # 1. Secure S3 bucket origin using OAC
    {
      origin_id                 = "s3-static-content"
      domain_name               = "my-bucket.s3.us-east-1.amazonaws.com"
      use_origin_access_control = true
    },
    # 2. Application Load Balancer origin for APIs
    {
      origin_id   = "alb-api"
      domain_name = "internal-alb-12345.us-east-1.elb.amazonaws.com"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  # Default cache behavior routes to S3 static content
  default_cache_behavior = {
    target_origin_id       = "s3-static-content"
    viewer_protocol_policy = "redirect-to-https"
    # Managed-CachingOptimized Cache Policy ID
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # Route api/* paths directly to the ALB origin without caching
  ordered_cache_behaviors = [
    {
      path_pattern           = "api/*"
      target_origin_id       = "alb-api"
      viewer_protocol_policy = "https-only"
      # Managed-CachingDisabled Cache Policy ID
      cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      # Managed-AllViewerExceptHostHeader Origin Request Policy ID
      origin_request_policy_id = "b689b0a8-53d0-40db-bafc-e24fe38d8344"
    }
  ]

  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  web_acl_id = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/my-waf/abc"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | A unique identifier prefix or suffix name for the distribution | `string` | n/a | yes |
| `enabled` | Whether the distribution is enabled to accept end-user requests | `bool` | `true` | no |
| `aliases` | Extra CNAMEs (alternate domain names), if any, for this distribution | `list(string)` | `[]` | no |
| `comment` | Any comments you want to include about the distribution | `string` | `""` | no |
| `default_root_object` | The object that you want CloudFront to return for root URLs | `string` | `"index.html"` | no |
| `price_class` | The price class for this distribution (`PriceClass_All`, `PriceClass_200`, `PriceClass_100`) | `string` | `"PriceClass_100"` | no |
| `web_acl_id` | The ARN of the WAFv2 Web ACL to associate with this distribution | `string` | `""` | no |
| `http_version` | The maximum HTTP version that you want viewers to use | `string` | `"http2and3"` | no |
| `is_ipv6_enabled` | Whether IPv6 is enabled for the distribution | `bool` | `true` | no |
| `create_origin_access_control` | Whether to create an Origin Access Control (OAC) for S3 origins | `bool` | `true` | no |
| `origin_access_control_name` | The name of the Origin Access Control | `string` | `""` | no |
| `origins` | A list of origins to configure for the distribution | `list(object)` | n/a | yes |
| `default_cache_behavior` | The default cache behavior configuration | `object` | n/a | yes |
| `ordered_cache_behaviors` | An ordered list of cache behaviors | `list(object)` | `[]` | no |
| `acm_certificate_arn` | The ARN of the ACM certificate to use (must be in us-east-1) | `string` | `""` | no |
| `ssl_support_method` | The SSL support method (`sni-only` or `vip`) | `string` | `"sni-only"` | no |
| `minimum_protocol_version` | The minimum SSL/TLS protocol version to use | `string` | `"TLSv1.2_2021"` | no |
| `restriction_type` | Method for geo-restrictions: `none`, `whitelist`, `blacklist` | `string` | `"none"` | no |
| `restriction_locations` | ISO 3166-1-alpha-2 country codes for geo-restrictions | `list(string)` | `[]` | no |
| `custom_error_responses` | A list of custom error response configurations | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `distribution_id` | The ID of the CloudFront distribution |
| `distribution_arn` | The ARN of the CloudFront distribution |
| `distribution_domain_name` | The domain name corresponding to the distribution |
| `distribution_hosted_zone_id` | The CloudFront Route53 zone ID (used for Route53 ALIAS records) |
| `origin_access_control_id` | The ID of the Origin Access Control created for S3 |
| `origin_access_control_arn` | The ARN of the Origin Access Control created for S3 |
