variable "name" {
  type        = string
  description = "The name of the EventBridge Rule"
}

variable "description" {
  type        = string
  default     = "EventBridge Rule managed by Terraform"
  description = "The description of the EventBridge Rule"
}

variable "create_bus" {
  type        = bool
  default     = false
  description = "Whether to create a custom EventBus"
}

variable "bus_name" {
  type        = string
  default     = "default"
  description = "The name of the EventBus. Used as the custom bus name if create_bus is true, or refers to an existing bus (like default) if create_bus is false."
}

variable "schedule_expression" {
  type        = string
  default     = null
  description = "The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)."
}

variable "event_pattern" {
  type        = string
  default     = null
  description = "The event pattern described a JSON object"
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Whether the rule should be enabled"
}

variable "create_target_role" {
  type        = bool
  default     = true
  description = "Whether to create an IAM role for EventBridge to invoke Step Functions or ECS tasks automatically"
}

variable "targets" {
  type        = any
  default     = {}
  description = "A map of targets for this rule. Properties include: arn, role_arn, input, input_path, dead_letter_arn, and ecs_target (task_definition_arn, subnets, etc.)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
