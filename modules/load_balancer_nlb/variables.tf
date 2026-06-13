variable "name" {
  description = "The name of the NLB"
  type        = string
}

variable "internal" {
  description = "If true, the NLB will be internal"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "A list of subnet IDs to associate with the NLB. Only used if subnet_mappings is empty."
  type        = list(string)
  default     = []
}

variable "subnet_mappings" {
  description = "A list of subnet mapping blocks. Used for mapping elastic IPs (EIPs) or private IPs to subnets."
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string)
    private_ipv4_address = optional(string)
  }))
  default = []
}

variable "enable_cross_zone_load_balancing" {
  description = "Indicates whether cross-zone load balancing is enabled in the NLB"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. Valid values: ipv4 or dualstack."
  type        = string
  default     = "ipv4"
}

variable "listeners" {
  description = "A list of listener configuration maps for TCP, UDP, TCP_UDP, and TLS protocols"
  type = list(object({
    port                     = number
    protocol                 = string # TCP, UDP, TCP_UDP, TLS
    default_target_group_arn = string
    ssl_policy               = optional(string)
    certificate_arn          = optional(string)
    alpn_policy              = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the NLB resources"
  type        = map(string)
  default     = {}
}
