variable "name" {
  description = "The name of the EMR cluster"
  type        = string
}

variable "release_label" {
  description = "The EMR release label"
  type        = string
  default     = "emr-6.15.0"
}

variable "applications" {
  description = "A list of applications to install on the EMR cluster"
  type        = list(string)
  default     = ["Hadoop", "Spark"]
}

variable "vpc_id" {
  description = "The ID of the VPC where the EMR cluster and security groups will be created"
  type        = string
}

variable "subnet_id" {
  description = "The VPC subnet ID in which to launch the cluster"
  type        = string
}

variable "is_private_subnet" {
  description = "Whether the subnet is a private subnet (requires a service access security group)"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "The EC2 key pair name for SSH access to the cluster nodes"
  type        = string
  default     = null
}

variable "ssh_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the master node"
  type        = list(string)
  default     = []
}

# KMS Key Configuration
variable "create_kms_key" {
  description = "Specifies whether to create a customer managed KMS key for EMR encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "The ARN of an existing KMS key to use if create_kms_key is set to false"
  type        = string
  default     = null
}

variable "kms_key_deletion_window" {
  description = "The deletion window in days for the created KMS key"
  type        = number
  default     = 30
}

variable "kms_key_policy" {
  description = "A custom KMS key policy JSON. If not specified, a default secure policy will be generated"
  type        = string
  default     = null
}

# EMR Security Configuration
variable "create_security_configuration" {
  description = "Specifies whether to create an EMR security configuration"
  type        = bool
  default     = true
}

variable "security_configuration" {
  description = "A custom EMR security configuration JSON string. If provided, it overrides all other encryption variables"
  type        = string
  default     = null
}

variable "security_configuration_name" {
  description = "The name of an existing EMR security configuration to use if create_security_configuration is false"
  type        = string
  default     = null
}

variable "enable_in_transit_encryption" {
  description = "Enables in-transit encryption. Requires certificate configuration variables"
  type        = bool
  default     = true
}

variable "in_transit_certificate_provider_type" {
  description = "The certificate provider type for in-transit encryption. Valid values: PEM, Custom"
  type        = string
  default     = "PEM"
}

variable "in_transit_certificate_s3_object" {
  description = "S3 URI pointing to the certificate ZIP file (required for PEM) or JAR file (required for Custom)"
  type        = string
  default     = null
}

variable "in_transit_certificate_provider_class" {
  description = "The Java class containing custom certificate provider logic (only used when provider type is Custom)"
  type        = string
  default     = null
}

variable "enable_at_rest_encryption" {
  description = "Enables encryption at rest for local disks and EMRFS on S3"
  type        = bool
  default     = true
}

variable "enable_ebs_encryption" {
  description = "Enables EBS volume encryption for EMR instances"
  type        = bool
  default     = true
}

variable "s3_encryption_mode" {
  description = "EMRFS S3 encryption mode. Valid values: SSE-S3, SSE-KMS, CSE-KMS"
  type        = string
  default     = "SSE-KMS"
}

# IAM Configurations
variable "create_service_role" {
  description = "Specifies whether to create the EMR Service IAM role"
  type        = bool
  default     = true
}

variable "service_role_arn" {
  description = "The ARN of an existing EMR Service IAM role if create_service_role is false"
  type        = string
  default     = null
}

variable "service_role_permissions_boundary" {
  description = "Permissions boundary ARN for the EMR Service IAM role"
  type        = string
  default     = null
}

variable "service_role_additional_policies" {
  description = "List of additional policy ARNs to attach to the EMR Service IAM role"
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Specifies whether to create the EMR EC2 instance profile"
  type        = bool
  default     = true
}

variable "instance_profile_name_or_arn" {
  description = "The name or ARN of an existing EMR EC2 instance profile if create_instance_profile is false"
  type        = string
  default     = null
}

variable "instance_profile_role_arn" {
  description = "The IAM role ARN associated with the existing instance profile if create_instance_profile is false (needed for KMS key policy)"
  type        = string
  default     = null
}

variable "instance_profile_role_permissions_boundary" {
  description = "Permissions boundary ARN for the EMR EC2 role"
  type        = string
  default     = null
}

variable "instance_profile_additional_policies" {
  description = "List of additional policy ARNs to attach to the EMR EC2 IAM role"
  type        = list(string)
  default     = []
}

# EMR Instance Groups Configuration
variable "master_instance_group" {
  description = "Configuration for the master instance group"
  type = object({
    instance_type  = string
    instance_count = optional(number, 1)
    bid_price      = optional(string)
    ebs_config = optional(list(object({
      size                 = number
      type                 = string
      volumes_per_instance = optional(number, 1)
      iops                 = optional(number)
    })), [])
  })
  default = {
    instance_type  = "m5.xlarge"
    instance_count = 1
    ebs_config = [
      {
        size                 = 50
        type                 = "gp3"
        volumes_per_instance = 1
      }
    ]
  }
}

variable "core_instance_group" {
  description = "Configuration for the core instance group"
  type = object({
    instance_type  = string
    instance_count = optional(number, 2)
    bid_price      = optional(string)
    ebs_config = optional(list(object({
      size                 = number
      type                 = string
      volumes_per_instance = optional(number, 1)
      iops                 = optional(number)
    })), [])
  })
  default = {
    instance_type  = "m5.xlarge"
    instance_count = 2
    ebs_config = [
      {
        size                 = 50
        type                 = "gp3"
        volumes_per_instance = 1
      }
    ]
  }
}

variable "task_instance_groups" {
  description = "Map of task instance groups to associate with the cluster"
  type = map(object({
    instance_type  = string
    instance_count = optional(number, 1)
    bid_price      = optional(string)
    ebs_config = optional(list(object({
      size                 = number
      type                 = string
      volumes_per_instance = optional(number, 1)
      iops                 = optional(number)
    })), [])
  }))
  default = {}
}

# Security Groups Customization
variable "create_security_groups" {
  description = "Specifies whether to create the EMR master, slave, and service access security groups"
  type        = bool
  default     = true
}

variable "emr_managed_master_security_group" {
  description = "The ID of an existing security group for the EMR master node if create_security_groups is false"
  type        = string
  default     = null
}

variable "emr_managed_slave_security_group" {
  description = "The ID of an existing security group for the EMR slave nodes if create_security_groups is false"
  type        = string
  default     = null
}

variable "service_access_security_group" {
  description = "The ID of an existing security group for the EMR service access if create_security_groups is false"
  type        = string
  default     = null
}

# Cluster Execution Configuration
variable "bootstrap_actions" {
  description = "List of bootstrap actions to run on cluster start"
  type = list(object({
    name = string
    path = string
    args = optional(list(string), [])
  }))
  default = []
}

variable "configurations_json" {
  description = "List of software configurations presented as a JSON string"
  type        = string
  default     = null
}

variable "keep_job_flow_alive_when_no_steps" {
  description = "Whether the cluster should stay active after steps complete"
  type        = bool
  default     = true
}

variable "termination_protection" {
  description = "Whether to enable termination protection for the cluster"
  type        = bool
  default     = false
}

variable "log_uri" {
  description = "S3 bucket path for EMR cluster logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
