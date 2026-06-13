variable "name" {
  description = "Name prefix for the resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs where the NAT Gateways should be created"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Should be true to create NAT Gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to create a single NAT Gateway shared across all private subnets"
  type        = bool
  default     = false
}

variable "create_eip" {
  description = "Should be true to create Elastic IPs for the NAT Gateways. If false, eip_allocation_ids must be provided."
  type        = bool
  default     = true
}

variable "eip_allocation_ids" {
  description = "List of existing EIP allocation IDs to associate with NAT Gateways (required if create_eip is false)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
