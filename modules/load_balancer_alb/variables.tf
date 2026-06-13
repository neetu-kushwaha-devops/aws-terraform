variable "name" {
  description = "The name of the ALB"
  type        = string
}

variable "internal" {
  description = "If true, the ALB will be internal"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "A list of subnet IDs to associate with the ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the ALB"
  type        = list(string)
  default     = []
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in the ALB"
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. Valid values: ipv4 or dualstack."
  type        = string
  default     = "ipv4"
}

variable "access_logs_enabled" {
  description = "Boolean to enable/disable access logs to S3"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "The S3 bucket name to store the access logs in"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "The S3 bucket prefix for the logs"
  type        = string
  default     = null
}

variable "http_enabled" {
  description = "Indicates whether HTTP (port 80) listener should be created"
  type        = bool
  default     = true
}

variable "http_port" {
  description = "The port for the HTTP listener"
  type        = number
  default     = 80
}

variable "http_redirect_to_https" {
  description = "Indicates whether HTTP traffic should be redirected to HTTPS (port 443)"
  type        = bool
  default     = false
}

variable "https_enabled" {
  description = "Indicates whether HTTPS (port 443) listener should be created"
  type        = bool
  default     = false
}

variable "https_port" {
  description = "The port for the HTTPS listener"
  type        = number
  default     = 443
}

variable "certificate_arn" {
  description = "The ARN of the default SSL server certificate. Required if HTTPS is enabled."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "The name of the SSL Policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "default_target_group_arn" {
  description = "The ARN of the default target group to forward traffic to"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "The ARN of the WAFv2 WebACL to associate with the ALB"
  type        = string
  default     = null
}

variable "additional_certificate_arns" {
  description = "A list of additional SSL certificate ARNs to attach to the HTTPS listener"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the ALB resources"
  type        = map(string)
  default     = {}
}
