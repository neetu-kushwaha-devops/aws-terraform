variable "name" {
  description = "Name to be used for the ECS cluster and as a prefix for other resources"
  type        = string
}

variable "cluster_settings" {
  description = "Configuration block for ECS cluster settings, e.g. containerInsights"
  type        = list(map(string))
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
}

variable "fargate_capacity_providers" {
  description = "List of Fargate capacity providers to associate with the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "ec2_capacity_providers" {
  description = "Map of EC2 capacity provider configurations. Key is the capacity provider name"
  type        = any
  default     = {}
}

variable "default_capacity_provider_strategy" {
  description = "The default capacity provider strategy for the cluster"
  type        = list(any)
  default     = []
}

# Task Definition variables
variable "create_task_definition" {
  description = "Whether to create an ECS task definition"
  type        = bool
  default     = false
}

variable "task_family" {
  description = "The family of the task definition. Defaults to var.name if null"
  type        = string
  default     = null
}

variable "container_definitions" {
  description = "The JSON container definitions. Required if create_task_definition is true"
  type        = string
  default     = ""
}

variable "task_definition_arn" {
  description = "ARN of an existing ECS task definition. Required if create_service is true and create_task_definition is false"
  type        = string
  default     = null
}

variable "task_cpu" {
  description = "The number of CPU units used by the task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "The amount of memory (in MiB) used by the task"
  type        = string
  default     = "512"
}

variable "network_mode" {
  description = "The network mode to use for the task definition"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "A list of launch types the task requires"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "create_execution_role" {
  description = "Whether to create a default ECS task execution role"
  type        = bool
  default     = true
}

variable "execution_role_arn" {
  description = "ARN of an existing IAM role for task execution. Used if create_execution_role is false"
  type        = string
  default     = null
}

variable "create_task_role" {
  description = "Whether to create a default ECS task role"
  type        = bool
  default     = true
}

variable "task_role_arn" {
  description = "ARN of an existing IAM role for the task. Used if create_task_role is false"
  type        = string
  default     = null
}

variable "volumes" {
  description = "List of volume definitions for the task definition"
  type        = any
  default     = []
}

# CloudWatch Log Group variables
variable "create_log_group" {
  description = "Whether to create a CloudWatch log group for the ECS task logs"
  type        = bool
  default     = true
}

variable "log_group_retention" {
  description = "Specifies the number of days you want to retain log events in the log group"
  type        = number
  default     = 30
}

# Service variables
variable "create_service" {
  description = "Whether to create an ECS service"
  type        = bool
  default     = false
}

variable "service_name" {
  description = "The name of the service. Defaults to var.name if null"
  type        = string
  default     = null
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "subnets" {
  description = "Subnet IDs associated with the task or service"
  type        = list(string)
  default     = []
}

variable "security_groups" {
  description = "Security groups associated with the task or service"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate only)"
  type        = bool
  default     = false
}

variable "load_balancers" {
  description = "List of load balancer configuration blocks for the service"
  type        = list(any)
  default     = []
}

variable "service_registries" {
  description = "List of service registry configuration blocks for the service"
  type        = list(any)
  default     = []
}

variable "service_capacity_provider_strategy" {
  description = "The capacity provider strategy to use for the service"
  type        = list(any)
  default     = []
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit of the number of running tasks that must remain running during a deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "The upper limit of the number of running tasks that can be running during a deployment"
  type        = number
  default     = 200
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks in the service"
  type        = string
  default     = "SERVICE"
}

# Autoscaling variables
variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the ECS service"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "The minimum number of tasks to run"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "The maximum number of tasks to run"
  type        = number
  default     = 10
}

variable "cpu_threshold" {
  description = "The target CPU utilization percentage for autoscaling"
  type        = number
  default     = 70
}

variable "memory_threshold" {
  description = "The target memory utilization percentage for autoscaling"
  type        = number
  default     = 70
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
