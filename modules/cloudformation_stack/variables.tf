variable "name" {
  type        = string
  description = "The name of the CloudFormation Stack or StackSet"
}

variable "create_stack" {
  type        = bool
  default     = true
  description = "Whether to create a standalone CloudFormation Stack"
}

variable "create_stack_set" {
  type        = bool
  default     = false
  description = "Whether to create a CloudFormation StackSet"
}

variable "template_body" {
  type        = string
  default     = null
  description = "Structure containing the template body (max size: 51,200 bytes). Conflict with template_url"
}

variable "template_url" {
  type        = string
  default     = null
  description = "Location of a file containing the template body (max size: 460,800 bytes). Conflict with template_body"
}

variable "parameters" {
  type        = map(string)
  default     = {}
  description = "Key-value pairs that specify input parameters for the CloudFormation template/StackSet"
}

variable "capabilities" {
  type        = list(string)
  default     = null
  description = "A list of capabilities. Valid values: CAPABILITY_IAM, CAPABILITY_NAMED_IAM, or CAPABILITY_AUTO_EXPAND"
}

variable "disable_rollback" {
  type        = bool
  default     = false
  description = "Set to true to disable rollback of the stack if stack creation failed"
}

variable "timeout_in_minutes" {
  type        = number
  default     = null
  description = "The amount of time that can pass before a stack status becomes CREATE_FAILED"
}

variable "iam_role_arn" {
  type        = string
  default     = null
  description = "The ARN of an IAM role that AWS CloudFormation assumes to create the stack"
}

variable "notification_arns" {
  type        = list(string)
  default     = null
  description = "SNS topic ARNs to publish stack related events"
}

variable "on_failure" {
  type        = string
  default     = null
  description = "Action to be taken if stack creation fails. Conflict with disable_rollback. Valid values: DO_NOTHING, ROLLBACK, or DELETE"
}

variable "policy_body" {
  type        = string
  default     = null
  description = "Structure containing the stack policy body. Conflict with policy_url"
}

variable "policy_url" {
  type        = string
  default     = null
  description = "Location of a file containing the stack policy. Conflict with policy_body"
}

# StackSet specific variables

variable "description" {
  type        = string
  default     = null
  description = "Description of the StackSet"
}

variable "administration_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM role that allows StackSets to manage service resources (Required for SELF_MANAGED permissions)"
}

variable "execution_role_name" {
  type        = string
  default     = null
  description = "The name of the IAM execution role to be assumed in target accounts (only for SELF_MANAGED permissions)"
}

variable "permission_model" {
  type        = string
  default     = "SELF_MANAGED"
  description = "Permission model for StackSet. Valid values: SELF_MANAGED or SERVICE_MANAGED"
}

variable "call_as" {
  type        = string
  default     = null
  description = "Specifies whether you are acting as an administrator or a delegated administrator. Valid values: SELF, DELEGATED_ADMIN"
}

variable "auto_deployment" {
  type = object({
    enabled                          = optional(bool)
    retain_stacks_on_account_removal = optional(bool)
  })
  default     = null
  description = "Configuration block for service-managed auto deployment behavior"
}

variable "managed_execution" {
  type = object({
    active = optional(bool)
  })
  default     = null
  description = "Configuration block for managed execution (non-concurrent deployments)"
}

variable "stack_set_deployments" {
  type = list(object({
    accounts                = optional(list(string))
    regions                 = optional(list(string))
    organizational_unit_ids = optional(list(string))
    account_filter_type     = optional(string)
    parameter_overrides     = optional(map(string))
    retain_stack            = optional(bool, false)
    call_as                 = optional(string)
    operation_preferences = optional(object({
      failure_tolerance_count      = optional(number)
      failure_tolerance_percentage = optional(number)
      max_concurrent_count         = optional(number)
      max_concurrent_percentage    = optional(number)
      region_concurrency_type      = optional(string)
      region_order                 = optional(list(string))
    }))
  }))
  default     = []
  description = "Deployments (instances) for the CloudFormation StackSet. Each element specifies accounts/OUs, regions, and optional overrides."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
