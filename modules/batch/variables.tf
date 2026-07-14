variable "name" {
  description = "Base name for AWS Batch resources"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# IAM Role Configurations
variable "create_service_role" {
  description = "Whether to create a custom IAM service role for AWS Batch"
  type        = bool
  default     = true
}

variable "service_role_arn" {
  description = "ARN of an existing IAM role for AWS Batch service. Used if create_service_role is false"
  type        = string
  default     = null
}

variable "service_role_additional_policies" {
  description = "List of additional IAM policy ARNs to attach to the AWS Batch service role"
  type        = list(string)
  default     = []
}

variable "create_instance_role" {
  description = "Whether to create a custom IAM instance profile/role for EC2 compute environments"
  type        = bool
  default     = true
}

variable "instance_role_arn" {
  description = "ARN of an existing IAM role for EC2 instances. Used if create_instance_role is false"
  type        = string
  default     = null
}

variable "instance_role_additional_policies" {
  description = "List of additional IAM policy ARNs to attach to the ECS instance role"
  type        = list(string)
  default     = []
}

# Job Execution & Task Roles
variable "create_job_execution_role" {
  description = "Whether to create a default ECS task execution role for Fargate/EC2 Batch jobs"
  type        = bool
  default     = true
}

variable "job_execution_role_additional_policies" {
  description = "List of additional IAM policy ARNs to attach to the job execution role"
  type        = list(string)
  default     = []
}

variable "create_job_role" {
  description = "Whether to create a default IAM role for the Batch job container execution"
  type        = bool
  default     = true
}

variable "job_role_additional_policies" {
  description = "List of additional IAM policy ARNs to attach to the job role"
  type        = list(string)
  default     = []
}

# Network Configurations
variable "vpc_id" {
  description = "The VPC ID where the security group will be created. Required if create_security_group is true"
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a dedicated security group for AWS Batch EC2 instances"
  type        = bool
  default     = true
}

variable "security_group_ingress" {
  description = "Ingress rules for the created security group"
  type = list(object({
    description      = optional(string, null)
    from_port        = optional(number, 0)
    to_port          = optional(number, 0)
    protocol         = optional(string, "-1")
    cidr_blocks      = optional(list(string), null)
    ipv6_cidr_blocks = optional(list(string), null)
    prefix_list_ids  = optional(list(string), null)
    security_groups  = optional(list(string), null)
    self             = optional(bool, null)
  }))
  default = []
}

variable "security_group_egress" {
  description = "Egress rules for the created security group"
  type = list(object({
    description      = optional(string, null)
    from_port        = optional(number, 0)
    to_port          = optional(number, 0)
    protocol         = optional(string, "-1")
    cidr_blocks      = optional(list(string), null)
    ipv6_cidr_blocks = optional(list(string), null)
    prefix_list_ids  = optional(list(string), null)
    security_groups  = optional(list(string), null)
    self             = optional(bool, null)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Launch Template Configurations (to enforce IMDSv2 and encrypted EBS volumes)
variable "create_launch_template" {
  description = "Whether to create a default launch template that enforces IMDSv2 and encrypted EBS volumes for EC2 compute resources"
  type        = bool
  default     = true
}

variable "launch_template_volume_size" {
  description = "Size of the encrypted EBS volume in GB"
  type        = number
  default     = 30
}

variable "launch_template_volume_type" {
  description = "Type of the encrypted EBS volume"
  type        = string
  default     = "gp3"
}

variable "launch_template_device_name" {
  description = "Block device name for EBS volume (e.g. /dev/xvda or /dev/xvdcz)"
  type        = string
  default     = "/dev/xvda"
}

variable "launch_template_http_put_response_hop_limit" {
  description = "The HTTP put response hop limit for IMDSv2"
  type        = number
  default     = 2
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to encrypt EBS volumes. If null, standard AWS managed EBS key is used"
  type        = string
  default     = null
}

# AWS Batch Resources Configurations
variable "compute_environments" {
  description = "Configuration map for AWS Batch compute environments"
  type = map(object({
    name         = optional(string, null)
    type         = optional(string, "MANAGED")
    state        = optional(string, "ENABLED")
    service_role = optional(string, null)
    compute_resources = optional(object({
      type                    = string
      max_vcpus               = number
      min_vcpus               = optional(number, 0)
      desired_vcpus           = optional(number, null)
      allocation_strategy     = optional(string, null)
      instance_type           = optional(list(string), null)
      instance_role           = optional(string, null)
      bid_percentage          = optional(number, null)
      ec2_key_pair            = optional(string, null)
      image_id                = optional(string, null)
      spot_iam_fleet_role     = optional(string, null)
      subnets                 = list(string)
      security_group_ids      = optional(list(string), null)
      launch_template_id      = optional(string, null)
      launch_template_name    = optional(string, null)
      launch_template_version = optional(string, "$Latest")
      ec2_configuration = optional(list(object({
        image_id_override = optional(string, null)
        image_type        = optional(string, null)
      })), [])
      tags = optional(map(string), {})
    }), null)
  }))
  default = {}
}

variable "job_queues" {
  description = "Configuration map for AWS Batch job queues"
  type = map(object({
    name     = optional(string, null)
    state    = optional(string, "ENABLED")
    priority = optional(number, 1)
    compute_environment_order = optional(list(object({
      order               = number
      compute_environment = string
    })), null)
    compute_environments = optional(list(string), [])
  }))
  default = {}
}

variable "job_definitions" {
  description = "Configuration map for AWS Batch job definitions"
  type = map(object({
    name                  = optional(string, null)
    type                  = optional(string, "container")
    container_properties  = optional(string, null)
    parameters            = optional(map(string), null)
    platform_capabilities = optional(list(string), null)
    propagate_tags        = optional(bool, null)
    retry_strategy = optional(object({
      attempts = optional(number, null)
      evaluate_on_exit = optional(list(object({
        action           = string
        on_exit_code     = optional(string, null)
        on_reason        = optional(string, null)
        on_status_reason = optional(string, null)
      })), [])
    }), null)
    timeout = optional(object({
      attempt_duration_seconds = optional(number, null)
    }), null)
  }))
  default = {}
}
