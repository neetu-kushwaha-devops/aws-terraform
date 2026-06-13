variable "name" {
  description = "Name for the resources"
  type        = string
}

variable "enable" {
  description = "Whether to enable the GuardDuty detector"
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "The frequency of notification about findings. Valid values are FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  type        = string
  default     = "SIX_HOURS"
}

variable "enable_s3_protection" {
  description = "Whether to enable S3 protection (S3 data events scanning)"
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Whether to enable EBS malware protection"
  type        = bool
  default     = true
}

variable "publishing_destination_arn" {
  description = "The ARN of the S3 bucket where findings will be published"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt GuardDuty findings"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to resources"
  type        = map(string)
  default     = {}
}
