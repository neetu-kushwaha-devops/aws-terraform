variable "name" {
  description = "The friendly name of the secret. If omitted, Terraform will generate a unique name."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflict with name."
  type        = string
  default     = null
}

variable "description" {
  description = "A description of the secret."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ARN or Id of the KMS key to use for encrypting the secret values in this secret. If not specified, AWS Secrets Manager uses the default KMS key (aws/secretsmanager)."
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before permanently deleting the secret. This value must be between 7 and 30 days, or 0 to force delete."
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "The recovery_window_in_days must be 0 or between 7 and 30."
  }
}

variable "secret_string" {
  description = "Specifies text data that you want to encrypt and store in this version of the secret. Can be plain text or a JSON string."
  type        = string
  default     = null
  sensitive   = true
}

variable "policy" {
  description = "A valid JSON document representing a resource policy."
  type        = string
  default     = null
}

variable "block_public_policy" {
  description = "Makes sure that the secret cannot be accessed publicly. Only valid when policy is set."
  type        = bool
  default     = true
}

variable "enable_rotation" {
  description = "Whether to enable automatic rotation for the secret."
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "The ARN of the Lambda function that can rotate the secret."
  type        = string
  default     = null
}

variable "rotation_rules" {
  description = "A structure that defines the rotation configuration for this secret."
  type = object({
    automatically_after_days = optional(number)
    duration                 = optional(string)
    schedule_expression      = optional(string)
  })
  default = null
}

variable "replicas" {
  description = "A list of replica configurations for the secret."
  type = list(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
