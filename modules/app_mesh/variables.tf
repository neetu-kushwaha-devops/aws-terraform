variable "name" {
  description = "The name of the service mesh"
  type        = string
}

variable "egress_filter_type" {
  description = "The egress filter type. Can be ALLOW_ALL or DROP_ALL."
  type        = string
  default     = "ALLOW_ALL"
}

variable "virtual_nodes" {
  description = "Map of virtual nodes to create"
  type = map(object({
    backends = optional(list(string), [])
    listeners = optional(list(object({
      port     = number
      protocol = string
    })), [])
    service_discovery_dns_hostname = optional(string)
  }))
  default = {}
}

variable "virtual_routers" {
  description = "Map of virtual routers to create"
  type = map(object({
    listeners = list(object({
      port     = number
      protocol = string
    }))
  }))
  default = {}
}

variable "routes" {
  description = "Map of routes to create"
  type = map(object({
    mesh_name          = optional(string)
    virtual_router_key = string
    http_route = optional(object({
      match_prefix = string
      targets = list(object({
        virtual_node_key = string
        weight           = number
      }))
    }))
  }))
  default = {}
}

variable "virtual_services" {
  description = "Map of virtual services to create"
  type = map(object({
    provider_virtual_node_key   = optional(string)
    provider_virtual_router_key = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
