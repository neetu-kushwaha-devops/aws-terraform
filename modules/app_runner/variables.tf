variable "name" {
  description = "Name of the AWS App Runner service"
  type        = string
}

variable "source_type" {
  description = "The type of the source repository. Valid values are IMAGE or CODE."
  type        = string

  validation {
    condition     = contains(["IMAGE", "CODE"], var.source_type)
    error_message = "source_type must be either IMAGE or CODE."
  }
}

variable "image_repository" {
  description = "Configuration for the image repository (used if source_type is IMAGE)"
  type = object({
    image_identifier      = string
    image_repository_type = string # ECR or ECR_PUBLIC
    image_configuration = optional(object({
      port                          = optional(string)
      start_command                 = optional(string)
      runtime_environment_variables = optional(map(string))
      runtime_environment_secrets   = optional(map(string))
    }))
  })
  default = null
}

variable "code_repository" {
  description = "Configuration for the code repository (used if source_type is CODE)"
  type = object({
    repository_url = string
    source_code_version = object({
      type  = string # BRANCH
      value = string # branch name, e.g. main
    })
    code_configuration = optional(object({
      configuration_source = string # REPOSITORY or API
      code_configuration_values = optional(object({
        runtime                       = string
        build_command                 = optional(string)
        start_command                 = optional(string)
        port                          = optional(string)
        runtime_environment_variables = optional(map(string))
        runtime_environment_secrets   = optional(map(string))
      }))
    }))
  })
  default = null
}

variable "auto_deployments_enabled" {
  description = "Whether to enable auto deployments on image push or code commit"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "The number of CPU units reserved for each instance of your App Runner service. Valid values are string representations (e.g. '0.25 vCPU', '0.5 vCPU', '1 vCPU', '2 vCPU', '4 vCPU' or '256', '512', '1024', '2048', '4096')"
  type        = string
  default     = "1024"
}

variable "memory" {
  description = "The amount of memory reserved for each instance of your App Runner service. Valid values are string representations (e.g. '0.5 GB', '1 GB', '2 GB', '3 GB', '4 GB', '6 GB', '8 GB', '12 GB' or '512', '1024', '2048', '3072', '4096', '6144', '8192', '12288')"
  type        = string
  default     = "2048"
}

# Auto Scaling configuration
variable "create_auto_scaling_config" {
  description = "Whether to create a new auto-scaling configuration"
  type        = bool
  default     = false
}

variable "auto_scaling_config_name" {
  description = "The name of the auto-scaling configuration. If null, defaults to service name."
  type        = string
  default     = null
}

variable "auto_scaling_max_concurrency" {
  description = "The maximum number of concurrent requests that an instance processes before App Runner scales up"
  type        = number
  default     = 100
}

variable "auto_scaling_max_size" {
  description = "The maximum number of instances that your service scales up to"
  type        = number
  default     = 25
}

variable "auto_scaling_min_size" {
  description = "The minimum number of instances that App Runner provisions for your service"
  type        = number
  default     = 1
}

variable "auto_scaling_configuration_arn" {
  description = "The ARN of an existing auto-scaling configuration. Used if create_auto_scaling_config is false."
  type        = string
  default     = null
}

# VPC Configuration
variable "create_vpc_connector" {
  description = "Whether to create a new VPC connector for outbound traffic"
  type        = bool
  default     = false
}

variable "vpc_connector_name" {
  description = "The name of the VPC connector. If null, defaults to service name."
  type        = string
  default     = null
}

variable "vpc_subnets" {
  description = "A list of IDs of subnets in your VPC for the VPC connector"
  type        = list(string)
  default     = []
}

variable "vpc_security_groups" {
  description = "A list of IDs of security groups in your VPC for the VPC connector"
  type        = list(string)
  default     = []
}

variable "vpc_connector_arn" {
  description = "The ARN of an existing VPC connector. Used if create_vpc_connector is false."
  type        = string
  default     = null
}

# Connection details for GitHub (only if source_type is CODE)
variable "create_connection" {
  description = "Whether to create a new App Runner connection for GitHub"
  type        = bool
  default     = false
}

variable "connection_name" {
  description = "The name of the App Runner connection"
  type        = string
  default     = null
}

variable "connection_provider_type" {
  description = "The source code connection provider type. Only GITHUB is supported by AWS App Runner."
  type        = string
  default     = "GITHUB"
}

variable "connection_arn" {
  description = "The ARN of an existing connection. Used if create_connection is false and source_type is CODE."
  type        = string
  default     = null
}

# IAM Roles configuration
variable "create_access_role" {
  description = "Whether to create an IAM role that grants App Runner permission to read ECR private repositories"
  type        = bool
  default     = true
}

variable "access_role_name" {
  description = "The name of the ECR access IAM role. If null, defaults to service name."
  type        = string
  default     = null
}

variable "access_role_arn" {
  description = "The ARN of an existing ECR access role. Used if create_access_role is false."
  type        = string
  default     = null
}

variable "create_instance_role" {
  description = "Whether to create an IAM role that your application code uses to access other AWS services"
  type        = bool
  default     = true
}

variable "instance_role_name" {
  description = "The name of the instance IAM role. If null, defaults to service name."
  type        = string
  default     = null
}

variable "instance_role_arn" {
  description = "The ARN of an existing instance role. Used if create_instance_role is false."
  type        = string
  default     = null
}

variable "instance_role_policies" {
  description = "A list of policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

# KMS Key Configuration
variable "kms_key_arn" {
  description = "The ARN of the KMS key that App Runner uses to encrypt copy of the repository or environmental secrets."
  type        = string
  default     = null
}

variable "is_publicly_accessible" {
  description = "Whether the App Runner service is publicly accessible via public URL"
  type        = bool
  default     = true
}

variable "health_check_configuration" {
  description = "Configuration block for the health check on your service"
  type = object({
    protocol            = optional(string) # TCP or HTTP
    path                = optional(string)
    interval            = optional(number)
    timeout             = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
