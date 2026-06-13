variable "name" {
  description = "The name of the FSx file system and Name tag"
  type        = string
}

variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from. FSx for Lustre supports only one subnet ID."
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of IDs for the security groups to associate with the file system."
  type        = list(string)
  default     = []
}

variable "storage_capacity" {
  description = "The storage capacity of the file system in GiB. For SCRATCH_2, PERSISTENT_1, PERSISTENT_2, SSD values must be 1200, 2400, 3600, or in multiples of 3600. For HDD, values must be in multiples of 6000."
  type        = number
  default     = 1200
}

variable "deployment_type" {
  description = "The deployment type for the file system. Valid values: SCRATCH_1, SCRATCH_2, PERSISTENT_1, PERSISTENT_2."
  type        = string
  default     = "SCRATCH_2"
}

variable "per_unit_storage_throughput" {
  description = "Required if deployment_type is PERSISTENT_1 or PERSISTENT_2. Describes the amount of read and write throughput for each 1 TiB of storage. SSD values: 50, 100, 200. HDD values: 12, 40."
  type        = number
  default     = null
}

variable "storage_type" {
  description = "The storage type for the file system. Valid values: SSD, HDD."
  type        = string
  default     = "SSD"
}

variable "kms_key_id" {
  description = "The ARN of the AWS KMS key to use to encrypt the file system at rest. If not specified, the default AWS managed key is used."
  type        = string
  default     = null
}

variable "import_path" {
  description = "An S3 URI (e.g., s3://bucket-name/optional-prefix) to import data from."
  type        = string
  default     = null
}

variable "export_path" {
  description = "An S3 URI (e.g., s3://bucket-name/optional-prefix) to export data to."
  type        = string
  default     = null
}

variable "imported_file_chunk_size" {
  description = "For files imported from a data repository, this value determines the size of the chunks (in MiB) that are imported."
  type        = number
  default     = null
}

variable "auto_import_policy" {
  description = "Specifies the option to configure an automatic import policy. Valid values: NONE, NEW, NEW_CHANGED, NEW_CHANGED_DELETED."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the file system."
  type        = map(string)
  default     = {}
}
