variable "name" {
  description = "The name of the service discovery service"
  type        = string
}

variable "namespace_id" {
  description = "The ID of the namespace to create the service in"
  type        = string
}

variable "dns_config" {
  description = "DNS configuration for the service discovery service. If omitted, the service will only support HTTP discovery."
  type = object({
    routing_policy = optional(string, "MULTIVALUE")
    dns_records = list(object({
      ttl  = number
      type = string
    }))
  })
  default = null
}

variable "health_check_config" {
  description = "Public DNS health check configuration. Only valid if public DNS namespace."
  type = object({
    failure_threshold = optional(number)
    resource_path     = optional(string)
    type              = optional(string)
  })
  default = null
}

variable "health_check_custom_config" {
  description = "Custom health check configuration (for HTTP namespaces or private DNS)."
  type = object({
    failure_threshold = optional(number, 1)
  })
  default = null
}

variable "instances" {
  description = "Map of instances to register with the service. Key is instance ID."
  type = map(object({
    attributes = map(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
