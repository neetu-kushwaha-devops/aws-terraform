variable "name" {
  description = "The name of the IAM role. Also used as a base name for associated resources."
  type        = string
}

variable "create_role" {
  description = "Whether to create the IAM role"
  type        = bool
  default     = true
}

variable "assume_role_policy" {
  description = "The assume role policy JSON document. If null, a default EC2 trust policy is used."
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of the IAM role"
  type        = string
  default     = "/"
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM Role managed by Terraform"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to attach to the IAM role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role"
  type        = number
  default     = 3600
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "create_policy" {
  description = "Whether to create a custom IAM policy"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "The name of the custom IAM policy. If null, defaults to name-policy."
  type        = string
  default     = null
}

variable "policy_description" {
  description = "The description of the custom IAM policy"
  type        = string
  default     = "Custom IAM Policy managed by Terraform"
}

variable "policy_path" {
  description = "Path of the custom IAM policy"
  type        = string
  default     = "/"
}

variable "policy_json" {
  description = "The custom IAM policy JSON document. Required if create_policy is true."
  type        = string
  default     = null
}

variable "attached_policy_arns" {
  description = "A list of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Whether to create an IAM instance profile"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile. If null, defaults to the role name."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
