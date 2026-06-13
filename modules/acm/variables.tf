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
  description = "Which method to use for validation (DNS or EMAIL)"
  type        = string
  default     = "DNS"
}

variable "zone_id" {
  description = "The default Route53 zone ID to use for DNS validation records"
  type        = string
  default     = ""
}

variable "domain_to_zone_map" {
  description = "A map of domain names to Route53 zone IDs. If specified, the zone ID for a domain validation option will be looked up here, falling back to var.zone_id"
  type        = map(string)
  default     = {}
}

variable "validate_certificate" {
  description = "Whether to create the aws_acm_certificate_validation resource to wait for validation"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
