# SNS Module

This module manages a Customer Managed or AWS Managed KMS-encrypted AWS SNS Topic, custom IAM policies, and subscription mappings.

## Features

- KMS encryption support (AWS Managed or Customer Managed key).
- Custom IAM topic policy attachment.
- Multiple SNS subscription mappings (SQS, Lambda, HTTP, Email, SMS, etc.).
- Support for FIFO/Standard topics.

## Usage Example

```hcl
module "sns_topic" {
  source = "./modules/sns"

  name                        = "app-notifications-topic"
  display_name                = "App Alerts"
  kms_master_key_id           = "alias/aws/sns" # or a custom KMS Key ARN
  fifo_topic                  = false
  content_based_deduplication = false

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublishFromS3",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:us-east-1:123456789012:app-notifications-topic"
    }
  ]
}
EOF

  subscriptions = {
    sqs_sub = {
      protocol             = "sqs"
      endpoint             = "arn:aws:sqs:us-east-1:123456789012:my-app-queue"
      raw_message_delivery = true
    }
    lambda_sub = {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
    }
  }

  tags = {
    Environment = "production"
    Project     = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the SNS topic. If FIFO, must end in `.fifo` | `string` | n/a | yes |
| `display_name` | The display name for the SNS topic | `string` | `null` | no |
| `kms_master_key_id` | The ID/ARN of an AWS-managed customer master key (CMK) or custom CMK for KMS encryption | `string` | `null` | no |
| `fifo_topic` | Boolean indicating whether or not to create a FIFO (first-in-first-out) topic | `bool` | `false` | no |
| `content_based_deduplication` | Enables content-based deduplication for FIFO topics | `bool` | `false` | no |
| `delivery_policy` | The SNS delivery policy | `string` | `null` | no |
| `policy` | The IAM policy document in JSON format to apply to the SNS topic | `string` | `null` | no |
| `subscriptions` | Map of SNS subscriptions to create. The key is a unique identifier. The value is an object configuring settings (protocol, endpoint, etc.) | `any` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `sns_topic_arn` | The ARN of the SNS topic |
| `sns_topic_id` | The ID of the SNS topic |
| `sns_topic_name` | The name of the SNS topic |
| `sns_topic_owner` | The owner of the SNS topic |
| `subscription_arns` | Map of subscription ARNs created |
