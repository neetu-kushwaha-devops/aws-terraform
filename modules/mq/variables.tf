variable "name" {
  type        = string
  description = "The name of the Amazon MQ broker. Also used to name associated resources like security groups."
}

variable "engine_type" {
  type        = string
  description = "The type of broker engine. Valid values: ActiveMQ, RabbitMQ."
  default     = "RabbitMQ"
}

variable "engine_version" {
  type        = string
  description = "The version of the broker engine. E.g. 3.13 or 5.18."
  default     = "3.13"
}

variable "host_instance_type" {
  type        = string
  description = "The broker's instance type. E.g. mq.t3.micro, mq.m5.large."
  default     = "mq.t3.micro"
}

variable "deployment_mode" {
  type        = string
  description = "The deployment mode of the broker. Valid values: SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, CLUSTER_MULTI_AZ."
  default     = "SINGLE_INSTANCE"
}

variable "storage_type" {
  type        = string
  description = "The storage type of the broker. Valid values: ebs or efs. RabbitMQ only supports ebs."
  default     = "ebs"
}

variable "authentication_strategy" {
  type        = string
  description = "The authentication strategy used to secure the broker. Valid values: simple, ldap. RabbitMQ only supports simple."
  default     = "simple"
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the broker is publicly accessible. Enforced to false by default for security."
  default     = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs. SINGLE_INSTANCE requires exactly one. ACTIVE_STANDBY_MULTI_AZ requires exactly two in different AZs. CLUSTER_MULTI_AZ requires two or three depending on deployment."
  default     = []
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs to associate with the broker. Combined with the created security group if create_security_group is true."
  default     = []
}

variable "create_security_group" {
  type        = bool
  description = "Whether to create a security group for the MQ broker."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the security group and broker will be deployed (required if create_security_group is true)."
  default     = null
}

variable "security_group_rules" {
  type = list(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
    description              = optional(string)
  }))
  description = "Custom security group rules to apply to the created security group."
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS customer master key (CMK) to use for encryption at rest. If not specified, Amazon MQ will use the AWS-managed KMS key."
  default     = null
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Whether to automatically upgrade minor versions during the maintenance window."
  default     = true
}

variable "create_configuration" {
  type        = bool
  description = "Whether to create a custom MQ configuration."
  default     = false
}

variable "configuration_name" {
  type        = string
  description = "The name of the custom configuration. Defaults to var.name-config."
  default     = null
}

variable "configuration_data" {
  type        = string
  description = "The configuration data in XML (ActiveMQ) or Cuttlefish (RabbitMQ) format."
  default     = ""
}

variable "configuration_id" {
  type        = string
  description = "The ID of an existing configuration to associate with the broker."
  default     = null
}

variable "configuration_revision" {
  type        = number
  description = "The revision of an existing configuration to associate with the broker."
  default     = null
}

variable "general_log_enabled" {
  type        = bool
  description = "Enable general logging to Amazon CloudWatch Logs."
  default     = true
}

variable "audit_log_enabled" {
  type        = bool
  description = "Enable audit logging to Amazon CloudWatch Logs (ActiveMQ only)."
  default     = false
}

variable "maintenance_window_start_time" {
  type = object({
    day_of_week = string
    time_of_day = string
    time_zone   = optional(string)
  })
  description = "The maintenance window start time."
  default     = null
}

variable "users" {
  type = list(object({
    username       = string
    password       = string
    groups         = optional(list(string))
    console_access = optional(bool)
  }))
  description = "List of users who can access the MQ broker console or API. Passwords should be marked sensitive."
  sensitive   = true
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
  default     = {}
}
