variable "name" {
  type        = string
  description = "The name of the network ACL"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the network ACL will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to associate with the network ACL"
  default     = []
}

variable "entries" {
  type        = list(map(string))
  description = "List of Network ACL rules. Map keys: rule_number, egress, protocol, rule_action, cidr_block, ipv6_cidr_block, from_port, to_port, icmp_type, icmp_code"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
