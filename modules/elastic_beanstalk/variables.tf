variable "name" {
  description = "The name of the Elastic Beanstalk Application and Environment."
  type        = string
}

variable "tier" {
  description = "The Elastic Beanstalk Environment tier. Valid values are WebServer or Worker."
  type        = string
  default     = "WebServer"
}

variable "solution_stack_name" {
  description = "The name of the solution stack to use. Cannot be used with platform_arn."
  type        = string
  default     = null
}

variable "platform_arn" {
  description = "The ARN of the platform version (solution stack) to use. Cannot be used with solution_stack_name."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The EC2 instance type to use."
  type        = string
  default     = "t3.micro"
}

variable "autoscale_min" {
  description = "The minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "autoscale_max" {
  description = "The maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "loadbalancer_type" {
  description = "The type of load balancer. Valid values: classic, application, network."
  type        = string
  default     = "application"
}

variable "vpc_id" {
  description = "The ID of the VPC where resources should be deployed."
  type        = string
  default     = null
}

variable "subnets" {
  description = "List of subnet IDs to deploy the EC2 instances."
  type        = list(string)
  default     = []
}

variable "elb_subnets" {
  description = "List of subnet IDs to deploy the Load Balancer. Only used if loadbalancer_type is classic or application, and vpc_id is specified."
  type        = list(string)
  default     = []
}

variable "elb_scheme" {
  description = "The scheme for the ELB. Valid values: public, internal."
  type        = string
  default     = "public"
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IP addresses with EC2 instances."
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate to attach to the load balancer for HTTPS."
  type        = string
  default     = null
}

variable "create_iam_resources" {
  description = "Whether to create IAM roles and instance profiles for the environment."
  type        = bool
  default     = true
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile name. Required if create_iam_resources is false."
  type        = string
  default     = null
}

variable "service_role_arn" {
  description = "Existing IAM service role ARN. Required if create_iam_resources is false."
  type        = string
  default     = null
}

variable "environment_properties" {
  description = "A map of key-value pairs representing application environment variables."
  type        = map(string)
  default     = {}
}

variable "setting_overrides" {
  description = "A list of configuration settings overrides. Each block requires namespace, name, value, and optionally resource."
  type = list(object({
    namespace = string
    name      = string
    value     = string
    resource  = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "A description of the Elastic Beanstalk environment."
  type        = string
  default     = "Elastic Beanstalk Environment managed by Terraform"
}

variable "application_description" {
  description = "A description of the Elastic Beanstalk application."
  type        = string
  default     = "Elastic Beanstalk Application managed by Terraform"
}
