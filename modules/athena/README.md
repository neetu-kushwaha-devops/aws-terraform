# AWS Athena Module

This module manages an Amazon Athena database, an Athena workgroup with query results storage configurations, and custom named queries. It enforces security best practices, such as forcing workgroup query results encryption and publishing metrics to CloudWatch.

## Features

- **Athena Database**: Creates an Athena database with optional database-level encryption.
- **Athena Workgroup**: Manages an Athena workgroup with built-in query limit controls and CloudWatch metrics.
- **Query Results Encryption**: Enforces SSE-S3 or SSE-KMS encryption for S3 query output locations.
- **Named Queries**: Supports configuring multiple pre-defined named queries.
- **Tags Integration**: Applies standard resource tags automatically merged with a resource Name tag.

## Usage Examples

### Example 1: Basic Usage (SSE-S3 Encryption)

This example sets up a standard Athena database and workgroup using S3-managed encryption (SSE-S3) for query results.

```hcl
module "athena_basic" {
  source = "./modules/athena"

  name                 = "analytics-basic-wg"
  database_name        = "app_analytics_db"
  query_results_bucket = "my-company-query-results-bucket"
  
  tags = {
    Environment = "development"
    Owner       = "data-platform"
  }
}
```

### Example 2: Secure Production Setup (SSE-KMS Encryption & Query Limit Controls)

This example enforces server-side encryption via a customer-managed KMS key and sets a query scan limit of 50 GB (`53,687,091,200` bytes) to prevent runaway query costs. It also creates reusable named queries.

```hcl
module "athena_production" {
  source = "./modules/athena"

  name                            = "analytics-prod-wg"
  database_name                   = "app_analytics_prod_db"
  database_comment                = "Production Application Analytics Database"
  database_force_destroy          = false
  
  # S3 bucket configuration
  query_results_bucket            = "my-prod-query-results-bucket"
  query_results_prefix            = "prod-queries/"

  # S3 output encryption configuration using KMS/SSE
  encryption_option               = "SSE_KMS"
  kms_key_arn                     = "arn:aws:kms:us-east-1:123456789012:key/a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"
  
  # Workgroup configuration controls
  enforce_workgroup_configuration = true
  bytes_scanned_cutoff_per_query   = 53687091200 # 50 GB query limit cutoff

  # Named Queries list
  named_queries = {
    daily_active_users = {
      name        = "daily-active-users-query"
      description = "Calculates daily active users from events tables"
      query       = "SELECT event_date, count(distinct user_id) as dau FROM app_analytics_prod_db.events GROUP BY event_date ORDER BY event_date DESC LIMIT 30;"
    }
    error_rates = {
      name        = "api-error-rates-query"
      description = "Calculates hourly API error rates"
      query       = "SELECT date_trunc('hour', event_time) as hourly, count(*) as err_count FROM app_analytics_prod_db.api_logs WHERE status >= 500 GROUP BY 1 ORDER BY 1 DESC;"
    }
  }

  tags = {
    Environment = "production"
    Project     = "mlops"
    Compliance  = "HIPAA"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix/identifier used to build Name tag and default resources | `string` | n/a | yes |
| `database_name` | The name of the Athena database. Must be alphanumeric and underscores only | `string` | n/a | yes |
| `database_comment` | A description/comment for the Athena database | `string` | `null` | no |
| `database_force_destroy` | Boolean indicating whether tables should be deleted on database destroy | `bool` | `false` | no |
| `enable_database_encryption` | Whether to configure encryption settings for the database itself | `bool` | `true` | no |
| `workgroup_name` | The name of the Athena workgroup. If not provided, defaults to `var.name` | `string` | `null` | no |
| `workgroup_description` | A description of the Athena workgroup | `string` | `null` | no |
| `workgroup_state` | State of the workgroup; must be `ENABLED` or `DISABLED` | `string` | `"ENABLED"` | no |
| `query_results_bucket` | The S3 bucket name where Athena query results will be stored | `string` | n/a | yes |
| `query_results_prefix` | S3 prefix/path inside the bucket where query results will be stored | `string` | `null` | no |
| `kms_key_arn` | The ARN of the KMS key to use for S3 output encryption. Required if using SSE_KMS or CSE_KMS | `string` | `null` | no |
| `encryption_option` | Encryption option for query results. Valid values: `SSE_S3`, `SSE_KMS`, `CSE_KMS`. If null, defaults to `SSE_KMS` when `kms_key_arn` is set, otherwise `SSE_S3` | `string` | `null` | no |
| `enforce_workgroup_configuration` | If true, the settings in this workgroup override any client-side settings | `bool` | `true` | no |
| `publish_cloudwatch_metrics_enabled` | If true, query metrics are published to CloudWatch | `bool` | `true` | no |
| `bytes_scanned_cutoff_per_query` | Maximum data scanned allowed per query in bytes. Must be at least 10,485,760 bytes (10 MB) | `number` | `null` | no |
| `named_queries` | A map of named queries to create. The key is used as the default name if 'name' is not provided | `map(object)` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `database_id` | The ID (name) of the Athena database |
| `database_name` | The name of the Athena database |
| `workgroup_id` | The ID of the Athena workgroup |
| `workgroup_arn` | The ARN of the Athena workgroup |
| `named_queries_details` | Map of named queries created with their details |
