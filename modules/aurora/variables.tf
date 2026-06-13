variable "name" {
  description = "The name prefix for the Aurora cluster and related resources"
  type        = string
}

variable "engine" {
  description = "The database engine to use (e.g. aurora-mysql, aurora-postgresql)"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "The database engine version"
  type        = string
  default     = null
}

variable "cluster_size" {
  description = "Number of static cluster instances to create. If autoscaling is enabled, this acts as the base number of instances."
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "The instance class to use. For Aurora Serverless v2, use 'db.serverless'"
  type        = string
  default     = "db.t3.medium"
}

variable "database_name" {
  description = "The name of the initial database to create"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs to create a DB subnet group"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Existing DB subnet group name. If provided, subnet_ids is ignored."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the cluster"
  type        = list(string)
  default     = []
}

variable "db_cluster_parameter_group_name" {
  description = "The name of the DB cluster parameter group to associate with the cluster"
  type        = string
  default     = null
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group to associate with the instances"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Must be between 1 and 35"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS key to use for cluster encryption"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If true, deletion protection will be enabled on the DB cluster"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The name of the final snapshot of the DB cluster when deleted"
  type        = string
  default     = null
}

variable "enable_serverlessv2" {
  description = "Enables Aurora Serverless v2 configuration on the cluster"
  type        = bool
  default     = false
}

variable "serverlessv2_min_capacity" {
  description = "The minimum capacity for Aurora Serverless v2 in ACUs"
  type        = number
  default     = 0.5
}

variable "serverlessv2_max_capacity" {
  description = "The maximum capacity for Aurora Serverless v2 in ACUs"
  type        = number
  default     = 16.0
}

variable "enable_autoscaling" {
  description = "Enables Application Auto Scaling for Aurora read replicas"
  type        = bool
  default     = false
}

variable "autoscaling_max_capacity" {
  description = "The maximum number of reader replicas for auto scaling"
  type        = number
  default     = 5
}

variable "autoscaling_min_capacity" {
  description = "The minimum number of reader replicas for auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_target_cpu" {
  description = "The target CPU utilization (percentage) to trigger scaling"
  type        = number
  default     = 70.0
}

variable "autoscaling_scale_in_cooldown" {
  description = "The cooldown period (seconds) before scaling in"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "The cooldown period (seconds) before scaling out"
  type        = number
  default     = 300
}

variable "publicly_accessible" {
  description = "Bool to control if instances are publicly accessible"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
