variable "name" {
  description = "The name of the EFS file system and Name tag"
  type        = string
}

variable "performance_mode" {
  description = "The file system performance mode. Can be generalPurpose or maxIO."
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the file system. Can be bursting, provisioned, or elastic."
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable if throughput_mode is provisioned."
  type        = number
  default     = null
}

variable "encrypted" {
  description = "If true, the disk will be encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN of the AWS KMS key to use to encrypt the file system. If not specified, the default EFS key is used."
  type        = string
  default     = null
}

variable "transition_to_ia" {
  description = "Indicates how long it takes to transition files to the IA storage class. Valid values: AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS, or null to disable."
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "transition_to_primary_storage_class" {
  description = "Policy for transitioning files out of IA storage. Valid values: AFTER_1_ACCESS or null to disable."
  type        = string
  default     = "AFTER_1_ACCESS"
}

variable "enable_backup_policy" {
  description = "Whether to enable automatic EFS backups via AWS Backup."
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs where the EFS mount targets will be created."
  type        = list(string)
  default     = []
}

variable "security_groups" {
  description = "A list of security group IDs to associate with the EFS mount targets."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the file system."
  type        = map(string)
  default     = {}
}
