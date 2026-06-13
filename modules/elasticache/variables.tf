variable "name" {
  description = "Name identifier for the ElastiCache cluster/replication group"
  type        = string
}

variable "engine" {
  description = "The engine to use. Supported values are redis and memcached"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The version number of the cache engine to use"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "node_count" {
  description = "The number of cache nodes (for Memcached) or cache clusters in the replication group (for Redis)"
  type        = number
  default     = 1
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections. If null, default is 6379 for redis, 11211 for memcached"
  type        = number
  default     = null
}

variable "description" {
  description = "Description of the replication group"
  type        = string
  default     = null
}

variable "create_parameter_group" {
  description = "Whether to create a new parameter group"
  type        = bool
  default     = true
}

variable "parameter_group_family" {
  description = "The family of the ElastiCache parameter group"
  type        = string
  default     = "redis7"
}

variable "parameter_group_name" {
  description = "Existing parameter group name. Ignored if create_parameter_group is true"
  type        = string
  default     = null
}

variable "parameter_group_parameters" {
  description = "A list of parameter maps to apply to the parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "create_subnet_group" {
  description = "Whether to create a new subnet group"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the subnet group"
  type        = list(string)
  default     = []
}

variable "subnet_group_name" {
  description = "Existing subnet group name. Ignored if create_subnet_group is true"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "One or more VPC security groups associated with the cache cluster"
  type        = list(string)
  default     = []
}

variable "automatic_failover_enabled" {
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. Only valid for Redis with node_count > 1"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Specifies whether Multi-AZ is enabled. Requires automatic_failover_enabled to be true"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit. Only valid for Redis engine"
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest. Only valid for Redis engine"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN of the KMS key that you want to use to encrypt data at rest"
  type        = string
  default     = null
}

variable "auth_token" {
  description = "The password used to access a protected Redis server. Must be sensitive. Only valid if transit_encryption_enabled is true"
  type        = string
  default     = null
  sensitive   = true
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for cluster maintenance"
  type        = string
  default     = null
}

variable "snapshot_window" {
  description = "The daily time range during which automated backups are created. Only valid for Redis engine"
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "The number of days for which ElastiCache will retain automatic snapshots. Only valid for Redis engine"
  type        = number
  default     = 0
}

variable "notification_topic_arn" {
  description = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to"
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
