variable "name" {
  type        = string
  description = "The name of the Step Functions State Machine"
}

variable "definition" {
  type        = string
  description = "The Amazon States Language (ASL) definition of the State Machine"
}

variable "type" {
  type        = string
  default     = "STANDARD"
  description = "The type of State Machine. Valid values: STANDARD, EXPRESS"
}

variable "create_role" {
  type        = bool
  default     = true
  description = "Whether to create the IAM execution role for Step Functions"
}

variable "role_arn" {
  type        = string
  default     = null
  description = "The IAM execution role ARN to use if create_role is false"
}

variable "policy_arns" {
  type        = list(string)
  default     = []
  description = "List of IAM policy ARNs to attach to the Step Functions execution role (only if create_role is true)"
}

variable "enable_xray" {
  type        = bool
  default     = false
  description = "Whether to enable AWS X-Ray tracing for the State Machine"
}

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Whether to enable CloudWatch logging for the State Machine"
}

variable "cloudwatch_logs_retention_in_days" {
  type        = number
  default     = 14
  description = "Specifies the number of days to retain execution log events in CloudWatch"
}

variable "log_level" {
  type        = string
  default     = "ALL"
  description = "Defines which category of execution history events are logged. Valid values: ALL, ERROR, FATAL, OFF"
}

variable "log_include_execution_data" {
  type        = bool
  default     = false
  description = "Whether to include execution data in the CloudWatch logs"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
