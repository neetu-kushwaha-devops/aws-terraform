variable "name" {
  description = "The name prefix to apply to resources"
  type        = string
}

variable "outpost_arn" {
  description = "The ARN of the AWS Outpost where the resources will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the Outpost subnet will be created"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the Outpost subnet"
  type        = string
}

variable "customer_owned_ipv4_pool" {
  description = "The Customer Owned IP (CoIP) pool ID"
  type        = string
  default     = null
}

variable "map_customer_owned_ip_on_launch" {
  description = "Specify true to indicate that network interfaces created in the subnet should be assigned a CoIP"
  type        = bool
  default     = false
}

variable "network_interfaces" {
  description = "Map of Outpost Local Network Interfaces (LNIs) to create"
  type = map(object({
    description = optional(string)
    private_ips = optional(list(string))
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
