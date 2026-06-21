variable "name" {
  description = "The base name used to construct resource tags (specifically the Name tag)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources. These will be merged with the Name tag"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "The primary domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "A list of subject alternative names (SANs) for the certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "The validation method to use (DNS, EMAIL, or NONE for Private CA certificates)"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL", "NONE"], var.validation_method)
    error_message = "The validation_method variable must be one of: DNS, EMAIL, NONE."
  }
}

variable "certificate_authority_arn" {
  description = "The ARN of the Private Certificate Authority (Private CA) to use for private certificates (when validation_method is NONE)"
  type        = string
  default     = null
}

variable "zone_id" {
  description = "The Route53 hosted zone ID to use for DNS validation records"
  type        = string
  default     = null
}

variable "validate_certificate" {
  description = "A boolean flag to enable certificate validation resource (aws_acm_certificate_validation) to wait for validation completion"
  type        = bool
  default     = true
}
