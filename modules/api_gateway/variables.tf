variable "name" {
  type        = string
  description = "The name of the API Gateway"
}

variable "description" {
  type        = string
  default     = "API Gateway managed by Terraform"
  description = "The description of the API Gateway"
}

variable "api_type" {
  type        = string
  default     = "HTTP"
  description = "The type of API Gateway. Valid values: HTTP, REST"
}

variable "stage_name" {
  type        = string
  default     = "$default"
  description = "The name of the API Gateway Stage"
}

variable "routes" {
  type        = any
  default     = {}
  description = "A map of routes configuration. Each route contains properties based on api_type."
}

variable "openapi_body" {
  type        = string
  default     = null
  description = "An OpenAPI definition string (only for REST API Gateway)"
}

variable "openapi_lambda_arns" {
  type        = list(string)
  default     = []
  description = "List of Lambda ARNs to grant API Gateway invoke execution access to (only if using openapi_body)"
}

variable "rest_endpoint_type" {
  type        = string
  default     = "REGIONAL"
  description = "The type of endpoint for REST API. Valid values: EDGE, REGIONAL, PRIVATE"
}

variable "enable_access_logging" {
  type        = bool
  default     = false
  description = "Whether to enable access logging for the API Stage"
}

variable "access_log_retention_in_days" {
  type        = number
  default     = 14
  description = "Specifies the number of days to retain access log events in CloudWatch"
}

variable "access_log_format" {
  type        = string
  default     = "{\"requestId\":\"$context.requestId\", \"ip\":\"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
  description = "The format of the access log statement"
}

variable "custom_domain_name" {
  type        = string
  default     = null
  description = "Custom domain name to associate with the API Gateway"
}

variable "acm_certificate_arn" {
  type        = string
  default     = null
  description = "The ARN of an ACM certificate for the custom domain"
}

variable "security_policy" {
  type        = string
  default     = "TLS_1_2"
  description = "The Transport Layer Security (TLS) version to use for custom domain. Valid values: TLS_1_0, TLS_1_2"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
