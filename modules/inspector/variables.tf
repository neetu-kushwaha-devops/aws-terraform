variable "enabled" {
  description = "Whether to enable AWS Inspector v2"
  type        = bool
  default     = true
}

variable "enable_ec2" {
  description = "Whether to enable EC2 scanning"
  type        = bool
  default     = true
}

variable "enable_ecr" {
  description = "Whether to enable ECR scanning"
  type        = bool
  default     = true
}

variable "enable_lambda" {
  description = "Whether to enable Lambda function scanning"
  type        = bool
  default     = true
}

variable "enable_lambda_code" {
  description = "Whether to enable Lambda code scanning (requires Lambda function scanning to be enabled)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to resources (where supported)"
  type        = map(string)
  default     = {}
}

variable "account_ids" {
  description = "List of AWS account IDs to enable Inspector v2. If not specified, defaults to the current caller account ID."
  type        = list(string)
  default     = []
}

