variable "parameter_prefix" {
  description = "A prefix to apply to all parameter names (e.g. '/app/dev/'). Must end with a slash if creating hierarchical paths."
  type        = string
  default     = ""
}

variable "parameters" {
  description = "A map of parameters to create in SSM Parameter Store. The key is used as a suffix for the parameter name if name is not explicitly provided."
  type = map(object({
    name            = optional(string)
    type            = string # String, StringList, SecureString
    value           = string
    description     = optional(string)
    tier            = optional(string, "Standard")
    key_id          = optional(string)
    allowed_pattern = optional(string)
    data_type       = optional(string, "text")
    tags            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.parameters : contains(["String", "StringList", "SecureString"], v.type)
    ])
    error_message = "Parameter type must be one of 'String', 'StringList', or 'SecureString'."
  }

  validation {
    condition = alltrue([
      for k, v in var.parameters : contains(["Standard", "Advanced", "Intelligent-Tiering"], v.tier)
    ])
    error_message = "Parameter tier must be one of 'Standard', 'Advanced', or 'Intelligent-Tiering'."
  }
}

variable "tags" {
  description = "A map of tags to apply to all SSM parameters created by this module."
  type        = map(string)
  default     = {}
}
