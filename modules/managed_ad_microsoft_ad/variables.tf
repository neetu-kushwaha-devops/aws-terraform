variable "name" {
  description = "The fully qualified domain name (FQDN) for the Managed Microsoft AD directory (e.g., corp.example.com)"
  type        = string
}

variable "short_name" {
  description = "The NetBIOS name for the directory (e.g., CORP)"
  type        = string
  default     = null
}

variable "password" {
  description = "The password for the directory administrator"
  type        = string
  sensitive   = true
}

variable "edition" {
  description = "The Microsoft AD edition. Can be Standard or Enterprise."
  type        = string
  default     = "Standard"
}

variable "vpc_id" {
  description = "The ID of the VPC where the directory is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs (must be in at least two different AZs) where the directory is deployed"
  type        = list(string)
}

variable "tags" {
  description = "A mapping of tags to assign to the directory resources"
  type        = map(string)
  default     = {}
}
