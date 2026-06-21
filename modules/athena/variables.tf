variable "name" {
  type        = string
  description = "Name prefix/identifier used to build Name tag and other default resources"
}

variable "database_name" {
  type        = string
  description = "The name of the Athena database. Must be alphanumeric and underscores only."
}

variable "database_comment" {
  type        = string
  default     = null
  description = "A description/comment for the Athena database"
}

variable "database_force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all tables should be deleted from the database so that the database can be destroyed without error."
}

variable "enable_database_encryption" {
  type        = bool
  default     = true
  description = "Whether to configure encryption settings for the database itself"
}

variable "workgroup_name" {
  type        = string
  default     = null
  description = "The name of the Athena workgroup. If not provided, defaults to var.name."
}

variable "workgroup_description" {
  type        = string
  default     = null
  description = "A description of the Athena workgroup."
}

variable "workgroup_state" {
  type        = string
  default     = "ENABLED"
  description = "State of the workgroup; must be ENABLED or DISABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.workgroup_state)
    error_message = "The workgroup_state must be ENABLED or DISABLED."
  }
}

variable "query_results_bucket" {
  type        = string
  description = "The S3 bucket name where Athena query results will be stored"
}

variable "query_results_prefix" {
  type        = string
  default     = null
  description = "S3 prefix/path inside the bucket where query results will be stored (e.g. 'results/')."
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "The ARN of the KMS key to use for S3 output encryption. If null, the module defaults to S3 managed keys (SSE_S3) or uses SSE_KMS if encryption_option is specified as SSE_KMS."
}

variable "encryption_option" {
  type        = string
  default     = null
  description = "Encryption option for query results. Valid values: SSE_S3, SSE_KMS, CSE_KMS. If null, defaults to SSE_KMS when kms_key_arn is set, otherwise SSE_S3."
  validation {
    condition     = var.encryption_option == null ? true : contains(["SSE_S3", "SSE_KMS", "CSE_KMS"], var.encryption_option)
    error_message = "The encryption_option must be one of SSE_S3, SSE_KMS, CSE_KMS."
  }
}

variable "enforce_workgroup_configuration" {
  type        = bool
  default     = true
  description = "If true, the settings in this workgroup override any client-side settings. Enforced as secure default."
}

variable "publish_cloudwatch_metrics_enabled" {
  type        = bool
  default     = true
  description = "If true, query metrics are published to CloudWatch. Enforced as secure default."
}

variable "bytes_scanned_cutoff_per_query" {
  type        = number
  default     = null
  description = "Maximum data scanned allowed per query in bytes. Must be at least 10,485,760 bytes (10 MB)."
  validation {
    condition     = var.bytes_scanned_cutoff_per_query == null ? true : var.bytes_scanned_cutoff_per_query >= 10485760
    error_message = "The bytes_scanned_cutoff_per_query must be at least 10,485,760 bytes (10 MB)."
  }
}

variable "named_queries" {
  type = map(object({
    name        = optional(string)
    query       = string
    description = optional(string)
    database    = optional(string)
  }))
  default     = {}
  description = "A map of named queries to create. The key is used as the lookup key, and the name of the query defaults to the map key if 'name' is not provided."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
