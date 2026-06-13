variable "name" {
  description = "The name of the WAFv2 Web ACL"
  type        = string
}

variable "scope" {
  description = "The scope of the Web ACL. Valid values are REGIONAL or CLOUDFRONT."
  type        = string
  default     = "REGIONAL"
}

variable "default_action" {
  description = "The default action for requests that do not match any rules. Can be 'allow' or 'block'."
  type        = string
  default     = "allow"
}

variable "enable_common_rule_set" {
  description = "Whether to enable the AWS Managed Common Rule Set"
  type        = bool
  default     = true
}

variable "enable_sqli_rule_set" {
  description = "Whether to enable the AWS Managed SQL Injection Rule Set"
  type        = bool
  default     = true
}

variable "enable_known_bad_inputs" {
  description = "Whether to enable the AWS Managed Known Bad Inputs Rule Set"
  type        = bool
  default     = true
}

variable "enable_ip_rate_limiting" {
  description = "Whether to enable IP-based rate limiting"
  type        = bool
  default     = true
}

variable "rate_limit_threshold" {
  description = "The maximum number of requests allowed from a single IP address in a 5-minute period"
  type        = number
  default     = 2000
}

variable "rate_limit_action" {
  description = "Action to perform when rate limit is exceeded. Valid values: 'block', 'count', 'captcha'"
  type        = string
  default     = "block"
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch Log Group for WAF streaming logs. Note: WAF log groups must start with the prefix 'aws-waf-logs-'"
  type        = bool
  default     = false
}

variable "log_group_retention_in_days" {
  description = "The number of days to retain WAF logs in the created CloudWatch log group"
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_arn" {
  description = "An existing CloudWatch Log Group ARN for WAF logs. If var.create_log_group is true, this is ignored and the created log group is used"
  type        = string
  default     = ""
}

variable "custom_rules" {
  description = "A list of custom rules to apply to the WAF Web ACL. Currently supports geo_match_statement and ip_set_reference_statement."
  type = list(object({
    name            = string
    priority        = number
    action          = optional(string)         # "allow", "block", "count", "captcha"
    override_action = optional(string, "none") # "none", "count"
    statement = object({
      geo_match_statement = optional(object({
        country_codes = list(string)
      }))
      ip_set_reference_statement = optional(object({
        arn = string
      }))
    })
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name                = string
      sampled_requests_enabled   = bool
    })
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the Web ACL"
  type        = map(string)
  default     = {}
}
