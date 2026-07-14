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
  type = map(object({
    catalog_id  = optional(string, null)
    description = optional(string, null)
    owner       = optional(string, null)
    retention   = optional(number, null)
    table_type  = optional(string, "EXTERNAL_TABLE")
    parameters  = optional(map(string), {})
    partition_keys = optional(list(object({
      name    = string
      type    = string
      comment = optional(string, null)
    })), [])
    storage_descriptor = optional(object({
      location          = optional(string, null)
      input_format      = optional(string, null)
      output_format     = optional(string, null)
      compressed        = optional(bool, null)
      number_of_buckets = optional(number, null)
      bucket_columns    = optional(list(string), null)
      parameters        = optional(map(string), null)
      columns = optional(list(object({
        name    = string
        type    = string
        comment = optional(string, null)
      })), [])
      serde_info = optional(object({
        name                  = optional(string, null)
        serialization_library = optional(string, null)
        parameters            = optional(map(string), null)
      }), null)
      sort_columns = optional(list(object({
        column     = string
        sort_order = number
      })), [])
      skewed_info = optional(object({
        skewed_column_names               = optional(list(string), null)
        skewed_column_values              = optional(list(string), null)
        skewed_column_value_location_maps = optional(map(string), null)
      }), null)
    }), null)
  }))
  default = {}
}

variable "crawlers" {
  description = "Map of Glue Crawlers to create. Keys are crawler names"
  type = map(object({
    description   = optional(string, null)
    classifiers   = optional(list(string), null)
    configuration = optional(string, null)
    schedule      = optional(string, null)
    s3_target = optional(list(object({
      path            = string
      exclusions      = optional(list(string), null)
      connection_name = optional(string, null)
      sample_size     = optional(number, null)
    })), [])
    dynamodb_target = optional(list(object({
      path      = string
      scan_all  = optional(bool, null)
      scan_rate = optional(number, null)
    })), [])
    jdbc_target = optional(list(object({
      connection_name = string
      path            = string
      exclusions      = optional(list(string), null)
    })), [])
    catalog_target = optional(list(object({
      database_name = string
      tables        = list(string)
    })), [])
    schema_change_policy = optional(object({
      delete_behavior = optional(string, "DEPRECATE_IN_DATABASE")
      update_behavior = optional(string, "UPDATE_IN_DATABASE")
    }), null)
    lineage_configuration = optional(object({
      crawler_lineage_settings = optional(string, null)
    }), null)
    lake_formation_configuration = optional(object({
      use_lake_formation_credentials = optional(bool, null)
      account_id                     = optional(string, null)
    }), null)
  }))
  default = {}
}

variable "jobs" {
  description = "Map of Glue Jobs to create. Keys are job names"
  type = map(object({
    description               = optional(string, null)
    connections               = optional(list(string), null)
    default_arguments         = optional(map(string), {})
    non_overridable_arguments = optional(map(string), {})
    max_retries               = optional(number, 0)
    timeout                   = optional(number, 2880)
    glue_version              = optional(string, "4.0")
    number_of_workers         = optional(number, null)
    worker_type               = optional(string, null)
    execution_class           = optional(string, null)
    command = object({
      name            = optional(string, "glueetl")
      script_location = string
      python_version  = optional(string, "3")
    })
    execution_property = optional(object({
      max_concurrent_runs = optional(number, 1)
    }), null)
    notification_property = optional(object({
      notify_delay_after = optional(number, null)
    }), null)
  }))
  default = {}
}

variable "connections" {
  description = "Map of Glue Connections to create. Keys are connection names"
  type = map(object({
    connection_type       = optional(string, "JDBC")
    connection_properties = optional(map(string), {})
    description           = optional(string, null)
    catalog_id            = optional(string, null)
    match_criteria        = optional(list(string), null)
    physical_connection_requirements = optional(object({
      availability_zone      = optional(string, null)
      security_group_id_list = optional(list(string), null)
      subnet_id              = optional(string, null)
    }), null)
  }))
  default = {}
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
