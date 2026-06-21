variable "name" {
  description = "The name of the resource share"
  type        = string
}

variable "allow_external_principals" {
  description = "Indicates whether principals outside your organization can be associated with a resource share"
  type        = bool
  default     = false
}

variable "principals" {
  description = "A list of principals to associate with the resource share. e.g., AWS Account IDs, Organization ARNs, OU ARNs"
  type        = list(string)
  default     = []
}

variable "resources" {
  description = "A list of resource ARNs to associate with the resource share"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource share resources"
  type        = map(string)
  default     = {}
}
