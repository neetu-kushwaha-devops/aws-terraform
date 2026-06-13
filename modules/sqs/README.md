# SQS Module

This module manages standard or FIFO AWS SQS Queues, KMS encryption configuration, custom IAM policies, and automatically sets up companion Dead Letter Queues (DLQs) with redrive policies.

## Features

- Standard and FIFO Queue types.
- KMS Encryption support using customer managed CMK or SQS-managed encryption keys.
- Highly customizable parameters (visibility timeout, retention period, message size, etc.).
- Optional automatic Dead Letter Queue (DLQ) generation with name formatting (handles FIFO suffixes correctly) and custom redrive settings.
- Standalone IAM Policy configuration.

## Usage Example

```hcl
module "sqs_queue" {
  source = "./modules/sqs"

  name                        = "app-processing-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 60
  message_retention_seconds   = 86400 # 1 day

  kms_master_key_id = "alias/aws/sqs"

  create_dlq        = true
  max_receive_count = 3

  tags = {
    Environment = "production"
    Project     = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the SQS queue. If FIFO queue, must end in `.fifo` | `string` | n/a | yes |
| `visibility_timeout_seconds` | The visibility timeout for the queue, in seconds | `number` | `30` | no |
| `message_retention_seconds` | The number of seconds Amazon SQS retains a message | `number` | `345600` (4 days) | no |
| `max_message_size` | The limit of how many bytes a message can contain | `number` | `262144` (256 KB) | no |
| `delay_seconds` | The time in seconds that the delivery of all messages will be delayed | `number` | `0` | no |
| `receive_wait_time_seconds` | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) | `number` | `0` | no |
| `fifo_queue` | Boolean designating a FIFO queue | `bool` | `false` | no |
| `content_based_deduplication` | Enables content-based deduplication for FIFO queues | `bool` | `false` | no |
| `deduplication_scope` | Specifies whether message deduplication occurs at the message group or queue level (FIFO only) | `string` | `null` | no |
| `fifo_throughput_limit` | Specifies whether the FIFO queue throughput limit applies to the entire queue or per message group | `string` | `null` | no |
| `kms_master_key_id` | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK | `string` | `null` | no |
| `kms_data_key_reuse_period_seconds` | The length of time in seconds for which SQS can reuse a data key | `number` | `300` | no |
| `sqs_managed_sse_enabled` | Boolean to enable server-side encryption (SSE-SQS) using SQS owned encryption keys | `bool` | `true` | no |
| `policy` | The JSON-formatted IAM policy to attach to the main SQS queue | `string` | `null` | no |
| `redrive_policy` | The JSON policy to set up the Dead Letter Queue redrive (Ignored if `create_dlq` is true) | `string` | `null` | no |
| `redrive_allow_policy` | The JSON policy to set up the Dead Letter Queue redrive allow policy | `string` | `null` | no |
| `create_dlq` | Set to true to automatically create a Dead Letter Queue (DLQ) for this queue | `bool` | `false` | no |
| `dlq_name` | The name of the DLQ. If null, defaults to `name-dlq` | `string` | `null` | no |
| `dlq_visibility_timeout_seconds` | The visibility timeout for the DLQ | `number` | `null` | no |
| `dlq_message_retention_seconds` | The number of seconds Amazon SQS retains a message in the DLQ | `number` | `1209600` (14 days) | no |
| `max_receive_count` | The number of times a message is delivered to the source queue before being moved to the DLQ | `number` | `5` | no |
| `dlq_tags` | Additional tags to assign to the DLQ resource | `map(string)` | `{}` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `queue_arn` | The ARN of the SQS queue |
| `queue_id` | The URL/ID of the SQS queue |
| `queue_name` | The name of the SQS queue |
| `dlq_arn` | The ARN of the Dead Letter Queue (if created) |
| `dlq_id` | The URL/ID of the Dead Letter Queue (if created) |
| `dlq_name` | The name of the Dead Letter Queue (if created) |
