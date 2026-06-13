variable "name" {
  description = "The name of the Auto Scaling Group"
  type        = string
}

variable "launch_template_id" {
  description = "The ID of the launch template to use"
  type        = string
  default     = null
}

variable "launch_template_name" {
  description = "The name of the launch template to use (alternative to launch_template_id)"
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "Launch template version to use. Can be a version number, $Latest, or $Default."
  type        = string
  default     = "$Latest"
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}

variable "target_group_arns" {
  description = "A list of target group ARNs to associate with the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Controls how health checking is done. Valid values: EC2 or ELB."
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time in seconds after an instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "force_delete" {
  description = "Allows deleting the ASG without waiting for all instances in the pool to terminate"
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "A list of termination policies to dictate how instances are selected for termination"
  type        = list(string)
  default     = ["Default"]
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. If not specified, no metrics are collected."
  type        = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect"
  type        = string
  default     = "1Minute"
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy"
  type        = string
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Whether new instances are protected from scale in by default"
  type        = bool
  default     = false
}

variable "service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  type        = string
  default     = null
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service"
  type        = number
  default     = null
}

variable "capacity_rebalance" {
  description = "Indicates whether capacity rebalance is enabled"
  type        = bool
  default     = false
}

variable "instance_refresh_strategy" {
  description = "The strategy to use when replacing instances. Valid values: Rolling or none."
  type        = string
  default     = "Rolling"
}

variable "instance_refresh_min_healthy_percentage" {
  description = "The minimum percentage of instances that must remain healthy during refresh"
  type        = number
  default     = 50
}

variable "instance_refresh_triggers" {
  description = "A list of triggers that will trigger an instance refresh (e.g. tag, launch_template)"
  type        = list(string)
  default     = ["launch_template"]
}

variable "enable_cpu_scaling_policy" {
  description = "Whether to enable CPU utilization target tracking scaling policy"
  type        = bool
  default     = false
}

variable "cpu_scaling_target_value" {
  description = "The target value for CPU utilization scaling (e.g., 70 for 70%)"
  type        = number
  default     = 70.0
}

variable "enable_alb_request_scaling_policy" {
  description = "Whether to enable ALB request count target tracking scaling policy"
  type        = bool
  default     = false
}

variable "alb_request_scaling_target_value" {
  description = "The target value for ALB request count scaling per target"
  type        = number
  default     = 1000.0
}

variable "alb_resource_label" {
  description = "The resource label for the target tracking ALB scaling policy, formatted as app/listener/targetgroup (e.g. app/my-alb/12345/targetgroup/my-tg/67890)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the ASG resources"
  type        = map(string)
  default     = {}
}
