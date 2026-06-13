# AWS WAFv2 Web ACL Terraform Module

This module manages AWS WAFv2 Web Access Control Lists (Web ACLs) with support for both regional (ALB/API Gateway) and global (CloudFront) scopes. It configures pre-defined managed rules, custom rate limits, custom rules, and CloudWatch log streaming.

## Features

- Dynamic scoping for `REGIONAL` or `CLOUDFRONT` environments.
- Integrates popular AWS Managed Rule Groups:
  - **Common Rule Set** (OWASP Core Rules)
  - **SQL Injection Rule Set** (SQLi)
  - **Known Bad Inputs Rule Set** (Known bad user agents, request patterns)
- Custom IP-based rate limiting rule (block, count, or captcha when thresholds are hit).
- Supports user-defined custom rules (e.g., Geo-blocking, IP whitelist/blacklist via IP sets).
- Optional CloudWatch Log Group generation (automatically prefixed with the mandatory `aws-waf-logs-` tag prefix) and association.

## Usage Example

```hcl
module "waf" {
  source = "./modules/waf"

  name   = "production-web-acl"
  scope  = "REGIONAL"

  enable_common_rule_set  = true
  enable_sqli_rule_set     = true
  enable_known_bad_inputs = true

  enable_ip_rate_limiting = true
  rate_limit_threshold    = 1000
  rate_limit_action       = "block"

  create_log_group            = true
  log_group_retention_in_days = 90

  custom_rules = [
    {
      name     = "GeoBlockRule"
      priority = 50
      action   = "block"
      statement = {
        geo_match_statement = {
          country_codes = ["KP", "IR", "SY"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlockRuleMetric"
        sampled_requests_enabled   = true
      }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the WAFv2 Web ACL | `string` | n/a | yes |
| `scope` | The scope of the Web ACL (`REGIONAL` or `CLOUDFRONT`) | `string` | `"REGIONAL"` | no |
| `default_action` | The default action for requests that do not match any rules (`allow` or `block`) | `string` | `"allow"` | no |
| `enable_common_rule_set` | Whether to enable the AWS Managed Common Rule Set | `bool` | `true` | no |
| `enable_sqli_rule_set` | Whether to enable the AWS Managed SQL Injection Rule Set | `bool` | `true` | no |
| `enable_known_bad_inputs` | Whether to enable the AWS Managed Known Bad Inputs Rule Set | `bool` | `true` | no |
| `enable_ip_rate_limiting` | Whether to enable IP-based rate limiting | `bool` | `true` | no |
| `rate_limit_threshold` | Max requests allowed from a single IP address in a 5-minute period | `number` | `2000` | no |
| `rate_limit_action` | Action when rate limit is exceeded (`block`, `count`, `captcha`) | `string` | `"block"` | no |
| `create_log_group` | Whether to create a CloudWatch Log Group for WAF streaming logs | `bool` | `false` | no |
| `log_group_retention_in_days` | Retention for created CloudWatch log group | `number` | `30` | no |
| `cloudwatch_log_group_arn` | Existing CloudWatch Log Group ARN for WAF logs | `string` | `""` | no |
| `custom_rules` | A list of custom rules to apply to the WAF Web ACL | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to the Web ACL | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `web_acl_arn` | The ARN of the WAFv2 Web ACL |
| `web_acl_id` | The ID of the WAFv2 Web ACL |
| `web_acl_name` | The name of the WAFv2 Web ACL |
| `log_group_name` | The name of the CloudWatch Log Group created for WAF logs |
| `log_group_arn` | The ARN of the CloudWatch Log Group created for WAF logs |
