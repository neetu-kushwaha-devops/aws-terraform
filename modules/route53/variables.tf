variable "zone_name" {
  description = "The name of the hosted zone"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new Route53 hosted zone or use an existing one"
  type        = bool
  default     = true
}

variable "existing_zone_id" {
  description = "The ID of the existing hosted zone (required if var.create_zone is false)"
  type        = string
  default     = ""
}

variable "private_zone" {
  description = "Whether the created hosted zone is a private zone associated with a VPC"
  type        = bool
  default     = false
}

variable "vpc_ids" {
  description = "A list of VPC IDs to associate with the private hosted zone"
  type        = list(string)
  default     = []
}

variable "vpc_regions" {
  description = "A map of VPC IDs to AWS regions. Fallback is the provider's default region"
  type        = map(string)
  default     = {}
}

variable "records" {
  description = "A list of map/objects representing Route53 records to create. Supports simple, weighted, latency, failover, geolocation, and alias configurations."
  type = list(object({
    name            = string
    type            = string
    ttl             = optional(number)
    records         = optional(list(string))
    set_identifier  = optional(string)
    health_check_id = optional(string)

    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }))

    weighted_routing_policy = optional(object({
      weight = number
    }))

    latency_routing_policy = optional(object({
      region = string
    }))

    failover_routing_policy = optional(object({
      type = string # PRIMARY or SECONDARY
    }))

    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the hosted zone"
  type        = map(string)
  default     = {}
}
