variable "name" {
  description = "Name of the CloudTrail."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store CloudTrail logs."
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs."
  type        = string
  default     = null
}

variable "is_multi_region_trail" {
  description = "Specifies whether the trail is created in the current region or in all regions."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled on the trail."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN to encrypt the CloudTrail logs."
  type        = string
  default     = null
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Specifies whether logging is enabled on the trail."
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "Specifies the name of the Amazon SNS topic defined for notification of log file delivery."
  type        = string
  default     = null
}

variable "is_organization_trail" {
  description = "Specifies whether the trail is an AWS Organizations trail."
  type        = bool
  default     = false
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create a CloudWatch log group and IAM role for CloudTrail log streaming."
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group to create or stream to."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retention period (in days) for CloudTrail logs in CloudWatch Logs."
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ARN to encrypt the CloudWatch Log Group."
  type        = string
  default     = null
}

variable "cloudwatch_logs_group_arn" {
  description = "Existing CloudWatch log group ARN to stream logs to (used if create_cloudwatch_log_group is false)."
  type        = string
  default     = null
}

variable "cloudwatch_logs_role_arn" {
  description = "Existing IAM role ARN for CloudTrail to send logs to CloudWatch (used if create_cloudwatch_log_group is false)."
  type        = string
  default     = null
}

variable "attach_s3_bucket_policy" {
  description = "Whether to attach a policy to the S3 bucket allowing CloudTrail to write logs."
  type        = bool
  default     = false
}

variable "event_selectors" {
  description = "Configuration blocks for event selectors."
  type        = list(any)
  default     = []
}

variable "insight_selectors" {
  description = "Configuration blocks for insight selectors."
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
