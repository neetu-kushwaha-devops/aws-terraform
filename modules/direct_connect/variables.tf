variable "name" {
  description = "Name for the Direct Connect resources"
  type        = string
}

variable "create_connection" {
  description = "Whether to provision a new Direct Connect physical connection"
  type        = bool
  default     = false
}

variable "connection_name" {
  description = "The name of the Direct Connect connection"
  type        = string
  default     = null
}

variable "bandwidth" {
  description = "The bandwidth of the Direct Connect connection (e.g., 50Mbps, 100Mbps, 1Gbps, 10Gbps)"
  type        = string
  default     = "1Gbps"
}

variable "location" {
  description = "The Direct Connect location (e.g., EqDC2)"
  type        = string
  default     = null
}

variable "provider_name" {
  description = "The name of the service provider associated with the connection"
  type        = string
  default     = null
}

variable "existing_connection_id" {
  description = "The ID of an existing Direct Connect connection to use if create_connection is false"
  type        = string
  default     = null
}

variable "create_dx_gateway" {
  description = "Whether to create a Direct Connect Gateway"
  type        = bool
  default     = true
}

variable "dx_gateway_name" {
  description = "The name of the Direct Connect Gateway"
  type        = string
  default     = null
}

variable "dx_gateway_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the Direct Connect Gateway"
  type        = number
  default     = 64512
}

variable "existing_dx_gateway_id" {
  description = "The ID of an existing Direct Connect Gateway to use if create_dx_gateway is false"
  type        = string
  default     = null
}

variable "dx_gateway_associations" {
  description = "Map of Gateway Associations (e.g. associating VGW or Transit Gateway with Direct Connect Gateway)"
  type = map(object({
    associated_gateway_id = string
    allowed_prefixes      = optional(list(string), [])
  }))
  default = {}
}

variable "private_vifs" {
  description = "Map of Private Virtual Interfaces (Private VIFs) to create"
  type = map(object({
    connection_id    = optional(string)
    name             = string
    vlan             = number
    address_family   = string # "ipv4" or "ipv6"
    bgp_asn          = number
    amazon_address   = optional(string)
    customer_address = optional(string)
    bgp_auth_key     = optional(string)
    dx_gateway_id    = optional(string)
    vpn_gateway_id   = optional(string)
    tags             = optional(map(string), {})
  }))
  default = {}
}

variable "public_vifs" {
  description = "Map of Public Virtual Interfaces (Public VIFs) to create"
  type = map(object({
    connection_id         = optional(string)
    name                  = string
    vlan                  = number
    address_family        = string # "ipv4" or "ipv6"
    bgp_asn               = number
    amazon_address        = optional(string)
    customer_address      = optional(string)
    bgp_auth_key          = optional(string)
    route_filter_prefixes = list(string)
    tags                  = optional(map(string), {})
  }))
  default = {}
}

variable "transit_vifs" {
  description = "Map of Transit Virtual Interfaces (Transit VIFs) to create"
  type = map(object({
    connection_id    = optional(string)
    name             = string
    vlan             = number
    address_family   = string # "ipv4" or "ipv6"
    bgp_asn          = number
    amazon_address   = optional(string)
    customer_address = optional(string)
    bgp_auth_key     = optional(string)
    dx_gateway_id    = optional(string)
    tags             = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
