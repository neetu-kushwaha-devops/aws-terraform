variable "name" {
  description = "The Redshift cluster identifier"
  type        = string
}

variable "node_type" {
  description = "The node type to be provisioned for the cluster (e.g. dc2.large, ra3.xlplus)"
  type        = string
  default     = "dc2.large"
}

variable "cluster_type" {
  description = "The cluster type. Must be single-node or multi-node"
  type        = string
  default     = "single-node"
}

variable "number_of_nodes" {
  description = "The number of nodes in the cluster. Required if cluster_type is multi-node"
  type        = number
  default     = 1
}

variable "database_name" {
  description = "The name of the first database to be created when the cluster is created"
  type        = string
  default     = "dev"
}

variable "master_username" {
  description = "Username for the master DB user. Must be alphanumeric and start with a letter"
  type        = string
  default     = "awsuser"
}

variable "master_password" {
  description = "Password for the master DB user. Must contain between 8 and 64 characters, at least one uppercase letter, one lowercase letter, and one number. Cannot contain @, ', \", /, or spaces"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "The port number on which the cluster accepts incoming connections"
  type        = number
  default     = 5439
}

variable "vpc_security_group_ids" {
  description = "A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster"
  type        = list(string)
  default     = []
}

variable "create_subnet_group" {
  description = "Whether to create a new Redshift subnet group"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs to create the subnet group from"
  type        = list(string)
  default     = []
}

variable "cluster_subnet_group_name" {
  description = "Existing Redshift subnet group name. Ignored if create_subnet_group is true"
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "If true, the cluster can be accessed from a public network"
  type        = bool
  default     = false
}

variable "enhanced_vpc_routing" {
  description = "If true, enhanced VPC routing is enabled"
  type        = bool
  default     = false
}

variable "encrypted" {
  description = "If true, the data in the cluster is encrypted at rest"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "The ARN of the AWS Key Management Service (AWS KMS) key for encrypting data at rest"
  type        = string
  default     = null
}

variable "iam_roles" {
  description = "A list of IAM Role ARNs to associate with the cluster"
  type        = list(string)
  default     = []
}

variable "logging_enabled" {
  description = "Whether to enable logging for the cluster"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "The name of an existing S3 bucket where you want to store auditing logs"
  type        = string
  default     = null
}

variable "logging_s3_key_prefix" {
  description = "The prefix applied to the log file names"
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system upgrades can occur. Format: ddd:hh24:mi-ddd:hh24:mi"
  type        = string
  default     = "sat:10:00-sat:10:30"
}

variable "automated_snapshot_retention_period" {
  description = "The number of days that automated snapshots are retained"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The identifier of the final snapshot that is to be created immediately before deleting the cluster"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
