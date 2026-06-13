variable "name" {
  description = "Name for the resources"
  type        = string
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch log group."
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "The name of the log group."
  type        = string
  default     = null
}

variable "log_group_retention_in_days" {
  description = "The log retention in days."
  type        = number
  default     = 30
}

variable "log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default     = null
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs to trigger on alarm transitions."
  type        = list(string)
  default     = []
}

# CPU Alarm Variables
variable "cpu_alarm_enabled" {
  description = "Enable built-in CPU utilization alarm."
  type        = bool
  default     = false
}

variable "cpu_alarm_name" {
  description = "Name of the CPU utilization alarm."
  type        = string
  default     = null
}

variable "cpu_alarm_threshold" {
  description = "Threshold for CPU utilization (percentage)."
  type        = number
  default     = 80
}

variable "cpu_alarm_evaluation_periods" {
  description = "Evaluation periods for CPU utilization."
  type        = number
  default     = 2
}

variable "cpu_alarm_period" {
  description = "Period (seconds) for CPU utilization."
  type        = number
  default     = 300
}

variable "cpu_alarm_namespace" {
  description = "Namespace for CPU utilization (e.g., AWS/EC2 or AWS/ECS)."
  type        = string
  default     = "AWS/EC2"
}

variable "cpu_alarm_metric_name" {
  description = "Metric name for CPU utilization."
  type        = string
  default     = "CPUUtilization"
}

variable "cpu_alarm_dimensions" {
  description = "Dimensions for the CPU alarm (e.g. InstanceId = i-123456)."
  type        = map(string)
  default     = {}
}

# Memory Alarm Variables
variable "memory_alarm_enabled" {
  description = "Enable built-in Memory utilization alarm."
  type        = bool
  default     = false
}

variable "memory_alarm_name" {
  description = "Name of the Memory utilization alarm."
  type        = string
  default     = null
}

variable "memory_alarm_threshold" {
  description = "Threshold for Memory utilization (percentage)."
  type        = number
  default     = 80
}

variable "memory_alarm_evaluation_periods" {
  description = "Evaluation periods for Memory utilization."
  type        = number
  default     = 2
}

variable "memory_alarm_period" {
  description = "Period (seconds) for Memory utilization."
  type        = number
  default     = 300
}

variable "memory_alarm_namespace" {
  description = "Namespace for Memory utilization (e.g., AWS/ECS or CWAgent)."
  type        = string
  default     = "AWS/ECS"
}

variable "memory_alarm_metric_name" {
  description = "Metric name for Memory utilization."
  type        = string
  default     = "MemoryUtilization"
}

variable "memory_alarm_dimensions" {
  description = "Dimensions for the Memory alarm."
  type        = map(string)
  default     = {}
}

# Billing Alarm Variables
variable "billing_alarm_enabled" {
  description = "Enable built-in Billing/EstimatedCharges alarm."
  type        = bool
  default     = false
}

variable "billing_alarm_name" {
  description = "Name of the Billing alarm."
  type        = string
  default     = null
}

variable "billing_alarm_threshold" {
  description = "Threshold for Billing alarm (USD/currency)."
  type        = number
  default     = 100
}

variable "billing_alarm_currency" {
  description = "Currency for the billing alarm."
  type        = string
  default     = "USD"
}

variable "billing_alarm_evaluation_periods" {
  description = "Evaluation periods for Billing alarm."
  type        = number
  default     = 1
}

variable "billing_alarm_period" {
  description = "Period (seconds) for Billing alarm (should be at least 21600 seconds/6 hours)."
  type        = number
  default     = 21600
}

# Custom Alarms
variable "custom_alarms" {
  description = "A map of custom metric alarms to create."
  type        = map(any)
  default     = {}
}

# Dashboard Variables
variable "create_dashboard" {
  description = "Whether to create a CloudWatch dashboard."
  type        = bool
  default     = false
}

variable "dashboard_name" {
  description = "The name of the dashboard."
  type        = string
  default     = null
}

variable "dashboard_body" {
  description = "The JSON body of the dashboard. If not provided and create_dashboard is true, a default dashboard will be generated."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
