variable "name" {
  type        = string
  description = "The name of the SQS queue. If FIFO queue, must end in .fifo"
}

variable "visibility_timeout_seconds" {
  type        = number
  default     = 30
  description = "The visibility timeout for the queue, in seconds"
}

variable "message_retention_seconds" {
  type        = number
  default     = 345600
  description = "The number of seconds Amazon SQS retains a message. Default is 4 days"
}

variable "max_message_size" {
  type        = number
  default     = 262144
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it"
}

variable "delay_seconds" {
  type        = number
  default     = 0
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
}

variable "receive_wait_time_seconds" {
  type        = number
  default     = 0
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling)"
}

variable "fifo_queue" {
  type        = bool
  default     = false
  description = "Boolean designating a FIFO queue"
}

variable "content_based_deduplication" {
  type        = bool
  default     = false
  description = "Enables content-based deduplication for FIFO queues"
}

variable "deduplication_scope" {
  type        = string
  default     = null
  description = "Specifies whether message deduplication occurs at the message group or queue level (FIFO only). Valid values are messageGroup and queue"
}

variable "fifo_throughput_limit" {
  type        = string
  default     = null
  description = "Specifies whether the FIFO queue throughput limit applies to the entire queue or per message group. Valid values are perQueue and perMessageGroupId"
}

variable "kms_master_key_id" {
  type        = string
  default     = null
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  default     = 300
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling KMS again"
}

variable "sqs_managed_sse_enabled" {
  type        = bool
  default     = true
  description = "Boolean to enable server-side encryption (SSE-SQS) using SQS owned encryption keys (ignored if kms_master_key_id is set)"
}

variable "policy" {
  type        = string
  default     = null
  description = "The JSON-formatted IAM policy to attach to the main SQS queue"
}

variable "redrive_policy" {
  type        = string
  default     = null
  description = "The JSON policy to set up the Dead Letter Queue redrive. (Ignored if create_dlq is true)"
}

variable "redrive_allow_policy" {
  type        = string
  default     = null
  description = "The JSON policy to set up the Dead Letter Queue redrive allow policy"
}

variable "create_dlq" {
  type        = bool
  default     = false
  description = "Set to true to automatically create a Dead Letter Queue (DLQ) for this queue"
}

variable "dlq_name" {
  type        = string
  default     = null
  description = "The name of the DLQ. If null and create_dlq is true, defaults to name-dlq (or name-dlq.fifo if FIFO)"
}

variable "dlq_visibility_timeout_seconds" {
  type        = number
  default     = null
  description = "The visibility timeout for the DLQ. If null, defaults to the main queue's visibility timeout"
}

variable "dlq_message_retention_seconds" {
  type        = number
  default     = 1209600
  description = "The number of seconds Amazon SQS retains a message in the DLQ. Default is 14 days"
}

variable "max_receive_count" {
  type        = number
  default     = 5
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue"
}

variable "dlq_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to assign to the DLQ resource"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
