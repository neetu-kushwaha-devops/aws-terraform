variable "create_tgw" {
  description = "Whether to create the Transit Gateway"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be associated with the Transit Gateway and related resources"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Managed by Terraform"
}

variable "amazon_side_asn" {
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session. The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs."
  type        = number
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted. Valid values: disable, enable."
  type        = string
  default     = "disable"
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table. Valid values: disable, enable."
  type        = string
  default     = "enable"
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table. Valid values: disable, enable."
  type        = string
  default     = "enable"
}

variable "dns_support" {
  description = "Whether DNS support is enabled. Valid values: disable, enable."
  type        = string
  default     = "enable"
}

variable "vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled. Valid values: disable, enable."
  type        = string
  default     = "enable"
}

variable "multicast_support" {
  description = "Whether Multicast support is enabled. Valid values: disable, enable."
  type        = string
  default     = "disable"
}

variable "transit_gateway_cidr_blocks" {
  description = "One or more IPv4 or IPv6 CIDR blocks for the transit gateway. Must be a size /24 CIDR block or larger for IPv4, or a size /64 CIDR block or larger for IPv6."
  type        = list(string)
  default     = []
}

variable "vpc_attachments" {
  description = "Map of VPC attachments to create. Key is the identifier for the attachment."
  type = map(object({
    vpc_id                                          = string
    subnet_ids                                      = list(string)
    dns_support                                     = optional(string, "enable")
    ipv6_support                                    = optional(string, "disable")
    appliance_mode_support                          = optional(string, "disable")
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    tags                                            = optional(map(string), {})
  }))
  default = {}
}

variable "route_tables" {
  description = "Map of custom Transit Gateway route tables to create."
  type = map(object({
    name = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "route_table_associations" {
  description = "Map of route table associations to create."
  type = map(object({
    route_table_key = string
    attachment_key  = string
  }))
  default = {}
}

variable "route_table_propagations" {
  description = "Map of route table propagations to create."
  type = map(object({
    route_table_key = string
    attachment_key  = string
  }))
  default = {}
}

variable "static_routes" {
  description = "Map of static routes to create in Transit Gateway route tables."
  type = map(object({
    route_table_key        = string
    destination_cidr_block = string
    attachment_key         = optional(string)
    blackhole              = optional(bool, false)
  }))
  default = {}
}

variable "share_tgw" {
  description = "Whether to share the Transit Gateway via Resource Access Manager (RAM)"
  type        = bool
  default     = false
}

variable "ram_resource_share_name" {
  description = "The name of the RAM resource share. Defaults to '<name>-share'"
  type        = string
  default     = null
}

variable "ram_principals" {
  description = "List of AWS Account IDs, Organizational Unit ARNs, or Organization ARNs to share the Transit Gateway with."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
