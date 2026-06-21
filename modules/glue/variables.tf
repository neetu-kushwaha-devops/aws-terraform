variable "name" {
  description = "A unique name to identify the resources, used as a prefix or base name"
  type        = string
}

variable "catalog_database_name" {
  description = "The name of the Glue Catalog Database. If not specified, a default database name using var.name will be created"
  type        = string
  default     = null
}

variable "catalog_database_description" {
  description = "Description of the Glue Catalog Database"
  type        = string
  default     = "Glue Catalog Database managed by Terraform"
}

variable "catalog_database_parameters" {
  description = "A map of key-value pairs that defines parameters and properties of the database"
  type        = map(string)
  default     = {}
}

variable "catalog_tables" {
  description = "Map of catalog tables to create within the Glue Database"
  type        = any
  default     = {}
}

variable "crawlers" {
  description = "Map of Glue Crawlers to create. Keys are crawler names"
  type        = any
  default     = {}
}

variable "jobs" {
  description = "Map of Glue Jobs to create. Keys are job names"
  type        = any
  default     = {}
}

variable "connections" {
  description = "Map of Glue Connections to create. Keys are connection names"
  type        = any
  default     = {}
}

variable "security_configuration_name" {
  description = "Optional custom name for the Glue Security Configuration. If not provided, var.name-security-config will be used"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key used for encrypting Glue Data Catalog, CloudWatch Logs, Job Bookmarks, and S3 data"
  type        = string
  default     = null
}

variable "enable_catalog_encryption" {
  description = "Whether to enable encryption-at-rest for the Glue Data Catalog metadata"
  type        = bool
  default     = true
}

variable "create_role" {
  description = "Whether to create a new IAM service role for AWS Glue execution"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "The ARN of an existing IAM role to use for Glue execution. Required if create_role is false"
  type        = string
  default     = null
}

variable "s3_read_write_paths" {
  description = "List of S3 bucket paths/ARNs that the Glue service role should have read-write access to"
  type        = list(string)
  default     = []
}

variable "s3_read_only_paths" {
  description = "List of S3 bucket paths/ARNs that the Glue service role should have read-only access to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the Glue resources"
  type        = map(string)
  default     = {}
}
