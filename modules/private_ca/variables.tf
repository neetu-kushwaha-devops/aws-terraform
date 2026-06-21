variable "name" {
  description = "The prefix name for all resources created by this module."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "type" {
  description = "Type of Certificate Authority. Valid values: ROOT, SUBORDINATE."
  type        = string
  default     = "ROOT"
  validation {
    condition     = contains(["ROOT", "SUBORDINATE"], var.type)
    error_message = "The type must be either ROOT or SUBORDINATE."
  }
}

variable "subject" {
  description = "Distinguished Name (DN) configuration for the CA subject."
  type = object({
    common_name                  = string
    organization                 = optional(string)
    organizational_unit          = optional(string)
    country                      = optional(string)
    state                        = optional(string)
    locality                     = optional(string)
    distinguished_name_qualifier = optional(string)
    generation_qualifier         = optional(string)
    given_name                   = optional(string)
    initials                     = optional(string)
    pseudonym                    = optional(string)
    surname                      = optional(string)
    title                        = optional(string)
  })
}

variable "key_algorithm" {
  description = "Type of key algorithm. Valid values: RSA_2048, RSA_4096, ECDSA_P256, ECDSA_P384, etc."
  type        = string
  default     = "RSA_2048"
}

variable "signing_algorithm" {
  description = "Algorithm to sign certificates. Valid values: SHA256WITHRSA, SHA384WITHRSA, SHA512WITHRSA, SHA256WITHECDSA, SHA384WITHECDSA, SHA512WITHECDSA."
  type        = string
  default     = "SHA256WITHRSA"
}

variable "enable_crl" {
  description = "Whether to enable Certificate Revocation List (CRL) generation."
  type        = bool
  default     = false
}

variable "crl_s3_bucket_name" {
  description = "The name of the S3 bucket to store CRLs. If enable_crl is true and this is null, an S3 bucket will be created automatically."
  type        = string
  default     = null
}

variable "crl_custom_cname" {
  description = "Custom CNAME for the CRL. E.g., crl.example.com"
  type        = string
  default     = null
}

variable "crl_expiration_in_days" {
  description = "Number of days before a CRL expires."
  type        = number
  default     = 7
}

variable "enable_ocsp" {
  description = "Whether to enable Online Certificate Status Protocol (OCSP) responder."
  type        = bool
  default     = false
}

variable "ocsp_custom_cname" {
  description = "Custom CNAME for the OCSP responder."
  type        = string
  default     = null
}

variable "parent_certificate_authority_arn" {
  description = "The ARN of the parent CA to sign this CA certificate. Required if type is SUBORDINATE."
  type        = string
  default     = null
}

variable "template_arn" {
  description = "Custom template ARN for the certificate. If null, a default template based on type (ROOT/SUBORDINATE) is used."
  type        = string
  default     = null
}

variable "validity" {
  description = "The validity period of the Certificate Authority certificate."
  type = object({
    type  = string
    value = string
  })
  default = {
    type  = "YEARS"
    value = "10"
  }
}

variable "create_ocsp_log_group" {
  description = "Whether to create a CloudWatch Log Group for OCSP/CA logging."
  type        = bool
  default     = true
}

variable "ocsp_log_retention_in_days" {
  description = "The retention period in days for the CloudWatch Log Group."
  type        = number
  default     = 30
}

variable "ocsp_log_group_kms_key_arn" {
  description = "The ARN of the KMS Key to encrypt the CloudWatch Log Group."
  type        = string
  default     = null
}
