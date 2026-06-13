variable "name" {
  description = "The name or name prefix of the launch template"
  type        = string
}

variable "use_name_prefix" {
  description = "Whether to use name prefix or exact name for the launch template"
  type        = bool
  default     = true
}

variable "ami" {
  description = "The AMI ID (image_id) to use for the launch template"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the launch template"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key name to use for the launch template"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "The base64-encoded user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate"
  type        = string
  default     = null
}

variable "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile to associate"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Whether to enable detailed monitoring for the launched instances"
  type        = bool
  default     = false
}

variable "block_device_mappings" {
  description = "List of block device mappings configuration maps for the launch template"
  type        = list(any)
  default     = []
}

variable "network_interfaces" {
  description = "List of network interface configurations to attach to the instances"
  type        = list(any)
  default     = []
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available (enabled or disabled)"
  type        = string
  default     = "enabled"
}

variable "metadata_http_tokens" {
  description = "Whether or not IMDSv2 is mandatory (required) or optional (optional)"
  type        = string
  default     = "required"
}

variable "metadata_http_put_response_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}

variable "metadata_instance_metadata_tags" {
  description = "Whether to enable access to instance tags from the metadata service (enabled or disabled)"
  type        = string
  default     = "disabled"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
