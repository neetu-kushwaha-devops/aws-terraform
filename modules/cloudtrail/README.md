# AWS CloudTrail Terraform Module

This module configures an AWS CloudTrail for auditing API actions across your AWS infrastructure. It supports multi-region trails, KMS encryption, log file validation, S3 bucket integration, and streaming to CloudWatch Logs.

## Features

- **Multi-region Trail:** Enabled by default to capture API calls across all AWS regions.
- **Log File Validation:** Verifies the integrity of CloudTrail log files.
- **KMS Encryption:** Optional encryption of logs in the S3 bucket using a custom KMS key.
- **CloudWatch Logs Streaming:** Automatically creates and streams events to a CloudWatch log group with a managed IAM role.
- **S3 Bucket Policy Attachment:** Optional automated S3 bucket policy attachment for CloudTrail write permissions.

## Usage

### Basic Example (Using Existing S3 Bucket)

```hcl
module "cloudtrail" {
  source = "./modules/cloudtrail"

  name           = "main-audit-trail"
  s3_bucket_name = "my-company-audit-logs"
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Advanced Example (With CloudWatch Logs Integration & KMS)

```hcl
module "cloudtrail" {
  source = "./modules/cloudtrail"

  name                                   = "secure-audit-trail"
  s3_bucket_name                         = "my-secure-audit-logs"
  s3_key_prefix                          = "cloudtrail"
  attach_s3_bucket_policy                = true
  is_multi_region_trail                  = true
  enable_log_file_validation             = true
  kms_key_id                             = "arn:aws:kms:us-east-1:123456789012:key/your-kms-key-id"
  
  # Stream logs to CloudWatch
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_name              = "/aws/cloudtrail/secure-audit-trail"
  cloudwatch_log_group_retention_in_days = 180

  event_selectors = [
    {
      read_write_type           = "All"
      include_management_events = true
    }
  ]

  tags = {
    Environment = "production"
    Security    = "high"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the CloudTrail. | `string` | n/a | yes |
| `s3_bucket_name` | Name of the S3 bucket to store CloudTrail logs. | `string` | n/a | yes |
| `s3_key_prefix` | S3 key prefix for CloudTrail logs. | `string` | `null` | no |
| `is_multi_region_trail` | Specifies whether the trail is created in the current region or in all regions. | `bool` | `true` | no |
| `enable_log_file_validation` | Specifies whether log file integrity validation is enabled on the trail. | `bool` | `true` | no |
| `kms_key_id` | KMS key ARN to encrypt the CloudTrail logs. | `string` | `null` | no |
| `include_global_service_events` | Specifies whether the trail is publishing events from global services such as IAM. | `bool` | `true` | no |
| `enable_logging` | Specifies whether logging is enabled on the trail. | `bool` | `true` | no |
| `sns_topic_name` | Specifies the name of the Amazon SNS topic defined for notification of log file delivery. | `string` | `null` | no |
| `is_organization_trail` | Specifies whether the trail is an AWS Organizations trail. | `bool` | `false` | no |
| `create_cloudwatch_log_group` | Whether to create a CloudWatch log group and IAM role for CloudTrail log streaming. | `bool` | `false` | no |
| `cloudwatch_log_group_name` | The name of the CloudWatch log group to create or stream to. | `string` | `null` | no |
| `cloudwatch_log_group_retention_in_days` | Retention period (in days) for CloudTrail logs in CloudWatch Logs. | `number` | `90` | no |
| `cloudwatch_log_group_kms_key_id` | KMS key ARN to encrypt the CloudWatch Log Group. | `string` | `null` | no |
| `cloudwatch_logs_group_arn` | Existing CloudWatch log group ARN to stream logs to (used if create_cloudwatch_log_group is false). | `string` | `null` | no |
| `cloudwatch_logs_role_arn` | Existing IAM role ARN for CloudTrail to send logs to CloudWatch (used if create_cloudwatch_log_group is false). | `string` | `null` | no |
| `attach_s3_bucket_policy` | Whether to attach a policy to the S3 bucket allowing CloudTrail to write logs. | `bool` | `false` | no |
| `event_selectors` | Configuration blocks for event selectors. | `list(any)` | `[]` | no |
| `insight_selectors` | Configuration blocks for insight selectors. | `list(any)` | `[]` | no |
| `tags` | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cloudtrail_id` | The name of the trail. |
| `cloudtrail_arn` | The ARN of the trail. |
| `cloudtrail_home_region` | The region in which the trail was created. |
| `cloudwatch_log_group_arn` | The ARN of the CloudWatch log group. |
| `cloudwatch_log_group_name` | The name of the CloudWatch log group. |
