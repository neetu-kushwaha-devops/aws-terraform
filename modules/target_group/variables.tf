variable "name" {
  description = "The name of the target group"
  type        = string
}

variable "port" {
  description = "The port on which targets receive traffic. Required unless target_type is lambda."
  type        = number
  default     = 80
}

variable "protocol" {
  description = "The protocol to use for routing traffic to the targets. Required unless target_type is lambda."
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "The identifier of the VPC in which to create the target group. Required unless target_type is lambda."
  type        = string
  default     = null
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets. Valid values: instance, ip, lambda, or alb."
  type        = string
  default     = "instance"
}

variable "deregistration_delay" {
  description = "The amount of time AWS Elastic Load Balancing waits before deregistering a target"
  type        = number
  default     = 300
}

variable "slow_start" {
  description = "The amount of time, in seconds, during which the load balancer sends a newly registered target a linearly increasing share of traffic"
  type        = number
  default     = 0
}

variable "load_balancing_algorithm_type" {
  description = "Determines how the load balancer selects targets when routing requests. Valid values: round_robin or least_outstanding_requests."
  type        = string
  default     = "round_robin"
}

variable "health_check_enabled" {
  description = "Indicates whether health checks are enabled"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "The destination for the health check request. Required for HTTP/HTTPS."
  type        = string
  default     = "/healthz"
}

variable "health_check_port" {
  description = "The port the load balancer uses when performing health checks on targets"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "The protocol the load balancer uses when performing health checks on targets. Defaults to the target group protocol."
  type        = string
  default     = null
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
}

variable "stickiness_enabled" {
  description = "Indicates whether target group stickiness is enabled"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "The type of sticky sessions. Valid values: lb_cookie, app_cookie, or source_ip (NLB)."
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "The time period, in seconds, during which requests from a client should be routed to the same target"
  type        = number
  default     = 86400
}

variable "stickiness_cookie_name" {
  description = "Name of the application cookie if stickiness_type is app_cookie"
  type        = string
  default     = null
}

variable "targets" {
  description = "A list of targets to attach to the target group dynamically"
  type = list(object({
    id                = string
    port              = optional(number)
    availability_zone = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the target group resources"
  type        = map(string)
  default     = {}
}
