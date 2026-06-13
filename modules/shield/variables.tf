variable "name" {
  description = "Name for the resources"
  type        = string
}

variable "enable" {
  description = "Whether to enable AWS Shield Advanced protections"
  type        = bool
  default     = true
}

variable "protected_resources" {
  description = "A map of resource friendly names to their resource ARNs to protect with Shield Advanced"
  type        = map(string)
  default     = {}
}

variable "enable_protection_group" {
  description = "Whether to create a Shield Advanced protection group"
  type        = bool
  default     = false
}

variable "protection_group_id" {
  description = "The unique identifier for the protection group"
  type        = string
  default     = "global-shield-protection-group"
}

variable "protection_group_aggregation" {
  description = "Defines how Shield combines resource data. Valid values: AVERAGE, MAX, SUM"
  type        = string
  default     = "MAX"
}

variable "protection_group_pattern" {
  description = "The pattern to choose resources. Valid values: ALL, ARBITRARY, BY_RESOURCE_TYPE"
  type        = string
  default     = "ALL"
}

variable "protection_group_resource_type" {
  description = "The resource type to include in protection group. Required if pattern is BY_RESOURCE_TYPE."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
