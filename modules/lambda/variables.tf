variable "name" {
  type        = string
  description = "The name of the Lambda function"
}

variable "description" {
  type        = string
  default     = ""
  description = "A description of the Lambda function"
}

variable "package_type" {
  type        = string
  default     = "Zip"
  description = "The Lambda deployment package type. Valid values: Zip, Image"
}

variable "handler" {
  type        = string
  default     = "handler.main"
  description = "The function entrypoint in the code (only for Zip package type)"
}

variable "runtime" {
  type        = string
  default     = "python3.10"
  description = "The Lambda runtime (only for Zip package type)"
}

variable "filename" {
  type        = string
  default     = null
  description = "Path to the function's deployment package (only for Zip package type)"
}

variable "s3_bucket" {
  type        = string
  default     = null
  description = "S3 bucket where the deployment package is located (only for Zip package type)"
}

variable "s3_key" {
  type        = string
  default     = null
  description = "S3 key of the deployment package (only for Zip package type)"
}

variable "s3_object_version" {
  type        = string
  default     = null
  description = "S3 object version of the deployment package (only for Zip package type)"
}

variable "source_code_hash" {
  type        = string
  default     = null
  description = "Used to trigger updates when the file changes (only for Zip package type)"
}

variable "image_uri" {
  type        = string
  default     = null
  description = "The ECR image URI (only for Image package type)"
}

variable "publish" {
  type        = bool
  default     = false
  description = "Whether to publish creation/change as a new Lambda Function Version"
}

variable "create_role" {
  type        = bool
  default     = true
  description = "Whether to create the IAM execution role"
}

variable "role_arn" {
  type        = string
  default     = null
  description = "IAM execution role ARN to use if create_role is false"
}

variable "policy_arns" {
  type        = list(string)
  default     = []
  description = "List of IAM policy ARNs to attach to the Lambda role (only if create_role is true)"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Map of environment variables that are accessible from the function code"
}

variable "timeout" {
  type        = number
  default     = 3
  description = "The amount of time your Lambda Function has to run in seconds"
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Amount of memory in MB your Lambda Function can use at runtime"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC subnet IDs to place the Lambda function in"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to associate with the Lambda function in the VPC"
}

variable "dead_letter_target_arn" {
  type        = string
  default     = null
  description = "The ARN of an SNS topic or SQS queue to notify when execution fails"
}

variable "reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "The amount of reserved concurrent execution for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
}

variable "provisioned_concurrent_executions" {
  type        = number
  default     = 0
  description = "The amount of provisioned concurrent execution for this lambda function. Requires publishing a version or creating an alias."
}

variable "alias_name" {
  type        = string
  default     = null
  description = "Optional alias name to create pointing to the function's version"
}

variable "cloudwatch_logs_retention_in_days" {
  type        = number
  default     = 14
  description = "Specifies the number of days you want to retain log events in the log group"
}

variable "create_function_url" {
  type        = bool
  default     = false
  description = "Whether to create a Lambda Function URL"
}

variable "function_url_auth_type" {
  type        = string
  default     = "NONE"
  description = "The authorization type for the Function URL. Valid values: NONE, AWS_IAM."
}

variable "function_url_cors" {
  type = object({
    allow_credentials = optional(bool, null)
    allow_headers     = optional(list(string), null)
    allow_methods     = optional(list(string), null)
    allow_origins     = optional(list(string), null)
    expose_headers    = optional(list(string), null)
    max_age           = optional(number, null)
  })
  default     = {}
  description = "CORS configuration for the Function URL"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
