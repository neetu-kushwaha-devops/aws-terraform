variable "name" {
  description = "Name for the resources"
  type        = string
}

variable "enable" {
  description = "Whether to enable AWS Config resources"
  type        = bool
  default     = true
}

variable "recorder_name" {
  description = "The name of the AWS Config configuration recorder"
  type        = string
  default     = "default"
}

variable "recorder_is_enabled" {
  description = "Whether the configuration recorder should record resource configurations"
  type        = bool
  default     = true
}

variable "recording_group_all_supported" {
  description = "Specifies whether AWS Config records configuration changes for every supported type of regional resource"
  type        = bool
  default     = true
}

variable "recording_group_include_global_resource_types" {
  description = "Specifies whether AWS Config includes all supported types of global resources (such as IAM resources)"
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Whether to create a new IAM role for AWS Config"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "The name of the IAM role for AWS Config. If null and create_iam_role is true, a name will be generated."
  type        = string
  default     = null
}

variable "iam_role_arn" {
  description = "The ARN of an existing IAM role to use for AWS Config (ignored if create_iam_role is true)"
  type        = string
  default     = null
}

variable "delivery_channel_name" {
  description = "The name of the AWS Config delivery channel"
  type        = string
  default     = "default"
}

variable "delivery_s3_bucket" {
  description = "The name of the S3 bucket to receive AWS Config configuration snapshots and history"
  type        = string
  default     = null
}

variable "delivery_s3_key_prefix" {
  description = "The prefix for the S3 bucket to receive AWS Config history"
  type        = string
  default     = null
}

variable "snapshot_delivery_frequency" {
  description = "The frequency with which AWS Config delivers configuration snapshots (e.g., One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours)"
  type        = string
  default     = "TwentyFour_Hours"
}

variable "enable_encrypted_volumes_rule" {
  description = "Whether to enable the AWS managed encrypted-volumes rule"
  type        = bool
  default     = true
}

variable "enable_root_account_mfa_rule" {
  description = "Whether to enable the AWS managed root-account-mfa rule"
  type        = bool
  default     = true
}

variable "custom_managed_rules" {
  description = "A map of custom AWS managed rules. Keys are friendly names, values are objects containing source_identifier and optional input_parameters."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to resources"
  type        = map(string)
  default     = {}
}
