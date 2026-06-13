variable "name" {
  description = "The name of the CodeDeploy application"
  type        = string
}

variable "compute_platform" {
  description = "The compute platform can be Server, Lambda, or ECS"
  type        = string
  default     = "Server"
  validation {
    condition     = contains(["Server", "Lambda", "ECS"], var.compute_platform)
    error_message = "The compute_platform variable must be one of: Server, Lambda, ECS."
  }
}

variable "deployment_group_name" {
  description = "The name of the deployment group. If not specified, defaults to {name}-dg"
  type        = string
  default     = null
}

variable "deployment_config_name" {
  description = "The deployment configuration name (e.g. CodeDeployDefault.OneAtATime, CodeDeployDefault.ECSAllAtOnce, CodeDeployDefault.LambdaCanary10Percent5Minutes)"
  type        = string
  default     = null
}

variable "create_service_role" {
  description = "Whether to create an IAM service role for CodeDeploy"
  type        = bool
  default     = true
}

variable "service_role_arn" {
  description = "ARN of an existing IAM role for CodeDeploy. Required if create_service_role is false"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Custom name for the IAM service role. If not specified, defaults to {name}-codedeploy-role"
  type        = string
  default     = null
}

variable "iam_role_policy_arns" {
  description = "Custom list of policy ARNs to attach to the IAM role. If empty and create_service_role is true, default managed policies will be attached based on compute_platform"
  type        = list(string)
  default     = []
}

variable "deployment_style" {
  description = "Map containing deployment style options: deployment_option (e.g. WITH_TRAFFIC_CONTROL, WITHOUT_TRAFFIC_CONTROL) and deployment_type (e.g. IN_PLACE, BLUE_GREEN)"
  type        = map(string)
  default     = null
}

variable "blue_green_deployment_config" {
  description = "Map containing blue/green deployment settings (deployment_ready_option, terminate_blue_instances_on_deployment_success, green_fleet_provisioning_option)"
  type        = any
  default     = null
}

variable "load_balancer_info" {
  description = "Load balancer information for the deployment group (elb_info, target_group_info, target_group_pair_info)"
  type        = any
  default     = null
}

variable "auto_rollback_enabled" {
  description = "Whether auto-rollback is enabled for the deployment group"
  type        = bool
  default     = true
}

variable "auto_rollback_events" {
  description = "List of events that trigger auto-rollback (e.g. DEPLOYMENT_FAILURE, DEPLOYMENT_STOP_ON_ALARM, DEPLOYMENT_STOP_ON_REQUEST)"
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE"]
}

variable "alarm_enabled" {
  description = "Whether CloudWatch alarms are enabled for the deployment group"
  type        = bool
  default     = false
}

variable "alarm_names" {
  description = "List of CloudWatch alarm names to associate with the deployment group"
  type        = list(string)
  default     = []
}

variable "ignore_poll_alarm_failure" {
  description = "Whether CodeDeploy should ignore poll alarm failure"
  type        = bool
  default     = false
}

variable "trigger_configurations" {
  description = "List of trigger configurations (events, name, target_arn)"
  type        = list(any)
  default     = []
}

variable "ec2_tag_filters" {
  description = "List of EC2 tag filters to select target instances for Server deployments (OR logic)"
  type        = list(any)
  default     = []
}

variable "ec2_tag_sets" {
  description = "List of EC2 tag sets for Server deployments (AND logic). Each set contains a list of ec2_tag_filters"
  type        = list(any)
  default     = []
}

variable "on_premises_instance_tag_filters" {
  description = "List of on-premises instance tag filters to select target instances"
  type        = list(any)
  default     = []
}

variable "auto_scaling_groups" {
  description = "List of Auto Scaling groups to associate with the deployment group (Server only)"
  type        = list(string)
  default     = []
}

variable "ecs_service" {
  description = "Map containing cluster_name and service_name for ECS deployments"
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
