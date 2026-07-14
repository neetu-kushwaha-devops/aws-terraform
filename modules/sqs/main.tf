terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  is_fifo = var.fifo_queue

  # Determine DLQ name automatically if not provided
  dlq_name = var.create_dlq ? (
    var.dlq_name != null ? var.dlq_name : (
      local.is_fifo ? "${replace(var.name, ".fifo", "")}-dlq.fifo" : "${var.name}-dlq"
    )
  ) : null
}

resource "aws_sqs_queue" "this" {
  name                        = var.name
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue ? var.fifo_throughput_limit : null

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? var.sqs_managed_sse_enabled : null

  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : var.redrive_policy

  redrive_allow_policy = var.redrive_allow_policy

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                        = local.dlq_name
  visibility_timeout_seconds  = var.dlq_visibility_timeout_seconds != null ? var.dlq_visibility_timeout_seconds : var.visibility_timeout_seconds
  message_retention_seconds   = var.dlq_message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = 0
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? var.sqs_managed_sse_enabled : null

  tags = merge(
    var.tags,
    var.dlq_tags,
    {
      "Name" = local.dlq_name
      "Role" = "dead-letter-queue"
    }
  )
}

resource "aws_sqs_queue_policy" "this" {
  count = var.policy != null ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = var.policy
}
