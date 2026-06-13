variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS"
  type        = string
  default     = "AES256"
}

variable "kms_key" {
  description = "The ARN of the KMS key to use when encryption_type is KMS. If not specified, the default AWS managed key is used"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "The JSON repository policy. If not provided, no policy is applied"
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "Whether to enable the default lifecycle policy"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "The maximum number of images to retain in the repository (used if enable_lifecycle_policy is true and lifecycle_policy is not provided)"
  type        = number
  default     = 30
}

variable "lifecycle_policy" {
  description = "A custom JSON lifecycle policy. If provided, it overrides the default lifecycle policy"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
