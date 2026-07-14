variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity. Can be PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined in attributes"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must also be defined in attributes"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "The number of read units for this table. Value is ignored if billing_mode is PAY_PER_REQUEST"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for this table. Value is ignored if billing_mode is PAY_PER_REQUEST"
  type        = number
  default     = null
}

variable "attributes" {
  description = "List of nested attribute definitions. Only required for attributes that will be used as hash or range keys in the table or its indexes"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "Describe GSI configurations for the DynamoDB table"
  type = list(object({
    name               = string
    hash_key           = string
    projection_type    = string
    range_key          = optional(string, null)
    read_capacity      = optional(number, null)
    write_capacity     = optional(number, null)
    non_key_attributes = optional(list(string), null)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Describe LSI configurations for the DynamoDB table"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), null)
  }))
  default = []
}

variable "stream_enabled" {
  description = "Indicates whether Streams are enabled (true) or disabled (false)"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = true
}

variable "server_side_encryption_enabled" {
  description = "Whether server-side encryption is enabled. If enabled is true and kms_key_arn is null, AWS owned customer master key is used"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption for this table"
  type        = string
  default     = null
}

variable "ttl_enabled" {
  description = "Indicates whether TTL is enabled"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
  default     = "ttl"
}

variable "tags" {
  description = "A map of tags to populate on the created table"
  type        = map(string)
  default     = {}
}
