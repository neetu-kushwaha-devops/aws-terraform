# AWS Simple Email Service (SES) Terraform Module

A production-ready, highly reusable Terraform module to configure Amazon Simple Email Service (SES) on AWS. This module handles domain validation, DKIM records, Route53 automation, individual email identity verification, incoming email receipt rules, and configuration sets with event tracking.

## Features

- **Domain Identity Verification:** Automatically creates domain identity resources and configures DKIM.
- **Route53 DNS Automation:** Creates TXT and CNAME records for domain and DKIM verification if a Route53 zone ID is provided.
- **Individual Email Verification:** Simplifies verifying lists of developer or notification email addresses.
- **Flexible Incoming Email Processing:** Generates receipt rule sets and active rule sets with support for multiple dynamic action blocks (S3 storage, SNS topic dispatch, Lambda execution, bounce, etc.).
- **Event Tracking and Analytics:** Sets up SES configuration sets and matching event destinations (SNS, CloudWatch, Kinesis Firehose) for tracking bounces, complaints, deliveries, sends, opens, and clicks.
- **Zero Hardcoding:** Fully parameterized for maximum flexibility.

## Usage Examples

### 1. Basic Domain Identity and DKIM verification with Route53

```hcl
module "ses" {
  source  = "./modules/ses"
  name    = "prod-mail"
  domain  = "example.com"
  zone_id = "Z0123456789ABCDEF"
  
  emails = [
    "alerts@example.com",
    "support@example.com"
  ]

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

### 2. Configuration Set Tracking with SNS Event Destination

```hcl
module "ses" {
  source                   = "./modules/ses"
  name                     = "marketing-campaigns"
  enable_configuration_set = true
  
  # Configure TLS and custom redirect tracking
  configuration_set_tls_policy             = "REQUIRE"
  configuration_set_custom_redirect_domain = "click.example.com"

  event_destinations = [
    {
      name           = "sns-bounces-and-complaints"
      enabled        = true
      matching_types = ["bounce", "complaint", "reject"]
      
      sns_destination = {
        topic_arn = "arn:aws:sns:us-east-1:123456789012:ses-alerts"
      }
    }
  ]
}
```

### 3. Advanced Incoming Email Processing (Receipt Rules)

```hcl
module "ses" {
  source                = "./modules/ses"
  name                  = "incoming-inbox"
  enable_incoming_email = true

  receipt_rules = [
    {
      name         = "store-and-notify"
      recipients   = ["info@example.com", "contact@example.com"]
      enabled      = true
      scan_enabled = true
      tls_policy   = "Require"

      # Save raw email payload to S3
      s3_actions = [
        {
          bucket_name       = "my-company-received-emails"
          object_key_prefix = "incoming/"
          position          = 1
        }
      ]

      # Trigger an SNS notification for downstream processing
      sns_actions = [
        {
          topic_arn = "arn:aws:sns:us-east-1:123456789012:new-email-event"
          position  = 2
          encoding  = "UTF-8"
        }
      ]
    },
    {
      name       = "trigger-lambda"
      recipients = ["api@example.com"]
      enabled    = true
      after      = "store-and-notify" # Explicit order execution

      lambda_actions = [
        {
          function_arn    = "arn:aws:lambda:us-east-1:123456789012:function:process-email"
          invocation_type = "Event"
          position        = 1
        }
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Base name for the SES resources | `string` | n/a | yes |
| `tags` | A map of tags to assign to the resources that support tagging | `map(string)` | `{}` | no |
| `domain` | The domain name to verify with SES | `string` | `null` | no |
| `zone_id` | The Route53 hosted zone ID to create verification and DKIM records in | `string` | `null` | no |
| `emails` | A list of individual email addresses to verify with SES | `list(string)` | `[]` | no |
| `enable_incoming_email` | Whether to enable incoming email processing by creating a receipt rule set and active rule set | `bool` | `false` | no |
| `receipt_rules` | List of receipt rules configuration for processing incoming emails | `list(object)` | `[]` | no |
| `enable_configuration_set` | Whether to create the SES configuration set and event destinations | `bool` | `true` | no |
| `configuration_set_reputation_metrics_enabled` | Whether to enable reputation metrics for the configuration set | `bool` | `false` | no |
| `configuration_set_sending_enabled` | Whether to enable sending for the configuration set | `bool` | `true` | no |
| `configuration_set_tls_policy` | Specifies whether messages that use the configuration set are required to use TLS. Can be REQUIRE or OPTIONAL. | `string` | `null` | no |
| `configuration_set_custom_redirect_domain` | The custom redirect domain for tracking open/click events | `string` | `null` | no |
| `event_destinations` | List of event destinations to create for the configuration set | `list(object)` | `[]` | no |

### `receipt_rules` Object Schema Detail

Each receipt rule block supports:
* `name` (string, required)
* `recipients` (list of strings, optional)
* `enabled` (bool, optional, default true)
* `scan_enabled` (bool, optional, default false)
* `tls_policy` (string, optional)
* `after` (string, optional - name of rule after which this should run)
* `s3_actions` (list of objects, optional)
  - `bucket_name` (string, required)
  - `object_key_prefix` (string, optional)
  - `topic_arn` (string, optional)
  - `position` (number, required)
  - `kms_key_arn` (string, optional)
* `sns_actions` (list of objects, optional)
  - `topic_arn` (string, required)
  - `position` (number, required)
  - `encoding` (string, optional)
* `lambda_actions` (list of objects, optional)
  - `function_arn` (string, required)
  - `invocation_type` (string, optional)
  - `topic_arn` (string, optional)
  - `position` (number, required)
* `add_header_actions` / `bounce_actions` / `stop_actions` / `workmail_actions` (objects correspond to standard AWS Provider arguments)

---

## Outputs

| Name | Description |
|------|-------------|
| `domain_identity_arn` | The ARN of the verified domain identity |
| `dkim_tokens` | The 3 DKIM tokens for the verified domain |
| `email_identities` | A map of verified individual email identities to their resource ARNs |
| `active_receipt_rule_set_name` | The name of the active receipt rule set |
| `configuration_set_arn` | The ARN of the configuration set |
| `configuration_set_id` | The ID of the configuration set |
| `receipt_rule_set_arn` | The ARN of the receipt rule set |

---

## Security Best Practices

### TODO(security)
1. **S3 Bucket Encryption**: When using the `s3_action` block in your receipt rules, ensure the target bucket is encrypted. Pass the `kms_key_arn` to ensure the raw emails are encrypted at rest using your KMS Customer Managed Key (CMK) rather than standard AWS-managed keys.
2. **Lambda & SNS Access Policies**: Ensure that the Lambda functions or SNS topics triggered by SES rule actions have appropriate resource-based access policies allowing the service principal `ses.amazonaws.com` permission to publish or invoke them.
3. **S3 Bucket Policy**: The target S3 bucket must have a bucket policy allowing `ses.amazonaws.com` `s3:PutObject` permission.
