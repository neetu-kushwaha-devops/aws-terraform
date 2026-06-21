variable "name" {
  description = "The name of the service discovery namespace"
  type        = string
}

variable "namespace_type" {
  description = "The namespace type. Can be HTTP, PRIVATE_DNS, or PUBLIC_DNS."
  type        = string
  default     = "PRIVATE_DNS"
  validation {
    condition     = contains(["HTTP", "PRIVATE_DNS", "PUBLIC_DNS"], var.namespace_type)
    error_message = "Namespace type must be one of: HTTP, PRIVATE_DNS, or PUBLIC_DNS."
  }
}

variable "vpc_id" {
  description = "The VPC ID to associate with the namespace. Required if namespace_type is PRIVATE_DNS."
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the namespace"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
