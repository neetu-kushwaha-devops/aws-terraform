variable "name" {
  description = "Name prefix to be used for resources and tagging."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "admins" {
  description = "List of ARNs of AWS IAM users or roles to set as Lake Formation administrators."
  type        = set(string)
  default     = []
}

variable "settings_catalog_id" {
  description = "Identifier for the Data Catalog. If not provided, the account ID is used."
  type        = string
  default     = null
}

variable "create_database_default_permissions" {
  description = "Up to 3 default permissions for newly created databases. Typically empty to revoke default permissions."
  type = list(object({
    permissions = set(string)
    principal   = string
  }))
  default = []
}

variable "create_table_default_permissions" {
  description = "Up to 3 default permissions for newly created tables. Typically empty to revoke default permissions."
  type = list(object({
    permissions = set(string)
    principal   = string
  }))
  default = []
}

variable "resources" {
  description = "Map of S3 locations or databases to register with Lake Formation."
  type = map(object({
    arn                     = string
    role_arn                = optional(string)
    use_service_linked_role = optional(bool, true)
    hybrid_access_enabled   = optional(bool, false)
  }))
  default = {}
}

variable "permissions" {
  description = "Map of permissions to grant to principals on various Lake Formation resources."
  type = map(object({
    principal                     = string
    permissions                   = set(string)
    permissions_with_grant_option = optional(set(string))
    catalog_id                    = optional(string)

    database = optional(object({
      name       = string
      catalog_id = optional(string)
    }))

    table = optional(object({
      database_name = string
      name          = optional(string)
      wildcard      = optional(bool)
      catalog_id    = optional(string)
    }))

    data_location = optional(object({
      arn        = string
      catalog_id = optional(string)
    }))

    lf_tag = optional(object({
      key        = string
      values     = set(string)
      catalog_id = optional(string)
    }))

    lf_tag_policy = optional(object({
      resource_type = string
      catalog_id    = optional(string)
      expressions = list(object({
        key    = string
        values = set(string)
      }))
    }))

    table_with_columns = optional(object({
      database_name = string
      name          = string
      column_names  = optional(set(string))
      catalog_id    = optional(string)
      wildcard = optional(object({
        excluded_column_names = optional(set(string))
      }))
    }))
  }))
  default = {}
}

variable "lf_tags" {
  description = "Map of LF-tags to create. The key is the tag key, value is an object defining tag settings."
  type = map(object({
    values     = set(string)
    catalog_id = optional(string)
  }))
  default = {}
}

variable "lf_tag_relations" {
  description = "Map of LF-tag relations to assign LF-tags to specific catalog resources."
  type = map(object({
    lf_tag = object({
      key        = string
      value      = string
      catalog_id = optional(string)
    })
    database = optional(object({
      name       = string
      catalog_id = optional(string)
    }))
    table = optional(object({
      database_name = string
      name          = optional(string)
      wildcard      = optional(bool)
      catalog_id    = optional(string)
    }))
    table_with_columns = optional(object({
      database_name = string
      name          = string
      column_names  = set(string)
      catalog_id    = optional(string)
    }))
  }))
  default = {}
}
