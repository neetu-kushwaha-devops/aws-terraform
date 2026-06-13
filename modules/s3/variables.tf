variable "name" {
  description = "The name of the S3 bucket and Name tag prefix. If bucket is not specified, this is used as the bucket name."
  type        = string
}

variable "bucket" {
  description = "The name of the bucket. If omitted, var.name will be used as the bucket name."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "acl" {
  description = "The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, and log-delivery-write. Note that if you specify an ACL, control_object_ownership should be set to true and object_ownership to BucketOwnerPreferred or ObjectWriter."
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Whether to block public access to the bucket. It is highly recommended to keep this true for security."
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "A boolean flag to enable or disable versioning."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use. Valid values are AES256 and aws:kms."
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. If not specified and sse_algorithm is aws:kms, the default aws/s3 key is used."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to configure. Each rule is a map matching the lifecycle configuration format."
  type        = any
  default     = []
}
