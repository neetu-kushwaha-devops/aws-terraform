variable "name" {
  description = "The name of the Global Accelerator"
  type        = string
}

variable "ip_address_type" {
  description = "The IP address type. Can be IPV4 or DUAL_STACK."
  type        = string
  default     = "IPV4"
}

variable "enabled" {
  description = "Indicates whether the accelerator is enabled"
  type        = bool
  default     = true
}

variable "flow_logs_enabled" {
  description = "Indicates whether flow logs are enabled"
  type        = bool
  default     = false
}

variable "flow_logs_s3_bucket" {
  description = "The name of the S3 bucket for flow logs"
  type        = string
  default     = null
}

variable "flow_logs_s3_prefix" {
  description = "The prefix of the S3 bucket for flow logs"
  type        = string
  default     = null
}

variable "listeners" {
  description = "Map of listeners and their target endpoint groups"
  type = map(object({
    port_ranges = list(object({
      from_port = number
      to_port   = number
    }))
    protocol = optional(string, "TCP")
    endpoint_groups = optional(map(object({
      endpoint_group_region = string
      health_check_port     = optional(number)
      health_check_protocol = optional(string)
      health_check_path     = optional(string)
      health_check_interval = optional(number)
      threshold_count       = optional(number)
      endpoints = list(object({
        endpoint_id                    = string
        weight                         = optional(number, 128)
        client_ip_preservation_enabled = optional(bool, true)
      }))
    })), {})
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
