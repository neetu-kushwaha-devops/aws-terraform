variable "name" {
  description = "The name of the KMS key. Also used as a base name for associated resources."
  type        = string
}

variable "description" {
  description = "The description of the key as visible in Amazon Web Services console"
  type        = string
  default     = "KMS Customer Managed Key"
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the time period ends, AWS KMS deletes the KMS key"
  type        = number
  default     = 30
}

variable "key_usage" {
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled"
  type        = bool
  default     = true
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key"
  type        = bool
  default     = false
}

variable "policy" {
  description = "A valid policy JSON document. If not specified, AWS will attach a default policy"
  type        = string
  default     = null
}

variable "aliases" {
  description = "A list of aliases to associate with the key. Do not include 'alias/' prefix, it will be added automatically"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the key"
  type        = map(string)
  default     = {}
}
