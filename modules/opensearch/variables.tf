variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "engine_version" {
  description = "The engine version for the OpenSearch domain. E.g. OpenSearch_2.11, OpenSearch_1.3, Elasticsearch_7.10"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "instance_type" {
  description = "The instance type for the OpenSearch cluster data nodes"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 2
}

variable "dedicated_master_enabled" {
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
  type        = bool
  default     = false
}

variable "dedicated_master_type" {
  description = "Instance type for the dedicated master nodes"
  type        = string
  default     = "t3.small.search"
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes in the cluster"
  type        = number
  default     = 3
}

variable "zone_awareness_enabled" {
  description = "Indicates whether zone awareness is enabled. Set to true for Multi-AZ"
  type        = bool
  default     = true
}

variable "availability_zone_count" {
  description = "Number of Availability Zones for the domain. Valid values are 2 or 3"
  type        = number
  default     = 2
}

variable "cluster_config" {
  description = "Map of cluster configurations to override. Designed for backwards compatibility."
  type        = any
  default     = {}
}

variable "warm_enabled" {
  description = "Indicates whether UltraWarm nodes are enabled"
  type        = bool
  default     = false
}

variable "warm_type" {
  description = "Instance type for the UltraWarm nodes"
  type        = string
  default     = "ultrawarm1.medium.search"
}

variable "warm_count" {
  description = "Number of UltraWarm nodes in the cluster"
  type        = number
  default     = 2
}

variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the domain"
  type        = bool
  default     = true
}

variable "ebs_volume_type" {
  description = "The type of EBS volumes. E.g. gp3, gp2"
  type        = string
  default     = "gp3"
}

variable "ebs_volume_size" {
  description = "The size of EBS volumes attached to data nodes (in GiB)"
  type        = number
  default     = 20
}

variable "ebs_iops" {
  description = "The baseline input/output operations per second (IOPS) for gp3 volumes (minimum 3000)"
  type        = number
  default     = 3000
}

variable "ebs_throughput" {
  description = "The baseline throughput for gp3 volumes (in MB/s, minimum 125)"
  type        = number
  default     = 125
}

variable "vpc_enabled" {
  description = "Whether to deploy the OpenSearch domain inside a VPC"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy the domain endpoints. If zone_awareness_enabled is true, this list size must match availability_zone_count"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "The KMS key ID to encrypt the OpenSearch domain data at rest. If not specified, the default AWS service key is used"
  type        = string
  default     = null
}

variable "tls_security_policy" {
  description = "The TLS security policy to apply to the HTTPS endpoint. E.g. Policy-Min-TLS-1-2-2019-07"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "fine_grained_access_control_enabled" {
  description = "Whether to enable fine-grained access control"
  type        = bool
  default     = false
}

variable "master_user_arn" {
  description = "The IAM ARN of the master user. If specified, internal user database must be disabled or not used as master"
  type        = string
  default     = null
}

variable "master_user_username" {
  description = "The master username for internal user database. Required if master_user_arn is null and fine_grained_access_control_enabled is true"
  type        = string
  default     = null
}

variable "master_user_password" {
  description = "The master password for internal user database. Required if master_user_arn is null and fine_grained_access_control_enabled is true"
  type        = string
  default     = null
  sensitive   = true
}

variable "custom_access_policy" {
  description = "A custom JSON policy string to restrict access to the OpenSearch domain. If null, a default permissive IAM policy is generated"
  type        = string
  default     = null
}

variable "advanced_options" {
  description = "Map of key-value string pairs to specify advanced configuration options"
  type        = map(string)
  default     = {}
}

variable "log_publishing_options" {
  description = "Configures log publishing options. List of objects defining log type, cloudwatch log group arn, and enabled flag."
  type = list(object({
    log_type      = string # INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS, AUDIT_LOGS
    log_group_arn = string
    enabled       = bool
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the OpenSearch domain"
  type        = map(string)
  default     = {}
}
