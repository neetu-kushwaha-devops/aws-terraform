variable "name" {
  type        = string
  description = "The name of the SNS topic. If FIFO, must end in .fifo"
}

variable "display_name" {
  type        = string
  default     = null
  description = "The display name for the SNS topic"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource"
}

variable "kms_master_key_id" {
  type        = string
  default     = null
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
}

variable "fifo_topic" {
  type        = bool
  default     = false
  description = "Boolean indicating whether or not to create a FIFO (first-in-first-out) topic"
}

variable "content_based_deduplication" {
  type        = bool
  default     = false
  description = "Enables content-based deduplication for FIFO topics"
}

variable "delivery_policy" {
  type        = string
  default     = null
  description = "The SNS delivery policy"
}

variable "policy" {
  type        = string
  default     = null
  description = "The IAM policy document in JSON format to apply to the SNS topic"
}

variable "subscriptions" {
  type        = any
  default     = {}
  description = "Map of SNS subscriptions to create. The key is a unique identifier (e.g. name/index) for each subscription, and the value is an object configuring the subscription settings (protocol, endpoint, endpoint_auto_confirms, filter_policy, filter_policy_scope, raw_message_delivery, redrive_policy, subscription_role_arn, delivery_policy)"
}
