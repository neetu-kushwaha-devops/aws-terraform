variable "instance_arn" {
  description = "The ARN of the SSO/Identity Center Instance"
  type        = string
}

variable "permission_sets" {
  description = "Map of permission sets to create"
  type = map(object({
    description         = optional(string)
    session_duration    = optional(string, "PT2H")
    inline_policy       = optional(string)
    managed_policy_arns = optional(list(string), [])
  }))
  default = {}
}

variable "account_assignments" {
  description = "List of SSO account assignments to create"
  type = list(object({
    permission_set_key = string
    principal_id       = string
    principal_type     = string # GROUP or USER
    target_id          = string # AWS Account ID
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
