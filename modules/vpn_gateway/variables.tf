variable "create_vpn_gateway" {
  description = "Whether to create the Virtual Private Gateway (VGW)"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be associated with the VPN Gateway and other resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to attach the VPN Gateway to"
  type        = string
  default     = null
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = number
  default     = null
}

variable "customer_gateways" {
  description = "Map of customer gateways to create. Key is a local identifier."
  type = map(object({
    bgp_asn     = number
    ip_address  = string
    device_name = optional(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "vpn_connections" {
  description = "Map of VPN connections to create. Key is a local identifier."
  type = map(object({
    customer_gateway_key       = string
    transit_gateway_id         = optional(string)
    static_routes_only         = optional(bool, false)
    local_ipv4_network_cidr    = optional(string)
    remote_ipv4_network_cidr   = optional(string)
    tunnel1_inside_cidr        = optional(string)
    tunnel2_inside_cidr        = optional(string)
    tunnel1_preshared_key      = optional(string)
    tunnel2_preshared_key      = optional(string)
    tunnel1_dpd_timeout_action = optional(string)
    tunnel2_dpd_timeout_action = optional(string)
    tunnel1_ike_versions       = optional(list(string))
    tunnel2_ike_versions       = optional(list(string))
    static_routes              = optional(list(string), [])
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "route_table_ids" {
  description = "List of Route Table IDs in the VPC where route propagation should be enabled"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
