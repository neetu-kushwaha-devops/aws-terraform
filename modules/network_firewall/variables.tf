variable "name" {
  description = "The prefix to apply to resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the Network Firewall is deployed"
  type        = string
}

variable "subnet_mappings" {
  description = "Set of subnets to deploy the firewall endpoints into"
  type = set(object({
    subnet_id = string
  }))
}

variable "stateless_rule_groups" {
  description = "List of stateless rule group configurations"
  type = list(object({
    priority     = number
    resource_arn = string
  }))
  default = []
}

variable "stateful_rule_groups" {
  description = "List of stateful rule group configurations"
  type = list(object({
    resource_arn = string
  }))
  default = []
}

variable "logging_destinations" {
  description = "Log destinations configuration"
  type = list(object({
    log_destination      = map(string)
    log_destination_type = string
    log_type             = string
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
