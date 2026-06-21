variable "name" {
  description = "The name of the access analyzer"
  type        = string
}

variable "type" {
  description = "The type of Analyzer. Can be ACCOUNT or ORGANIZATION."
  type        = string
  default     = "ACCOUNT"
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.type)
    error_message = "Analyzer type must be one of ACCOUNT or ORGANIZATION."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
