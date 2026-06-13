variable "name" {
  type        = string
  description = "The name of the security group"
}

variable "description" {
  type        = string
  description = "The description of the security group"
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the security group will be created"
}

variable "ingress" {
  type        = list(map(string))
  description = "List of ingress rules maps. Expected keys: from_port, to_port, protocol, cidr_blocks, description, security_groups, self"
  default     = []
}

variable "egress" {
  type        = list(map(string))
  description = "List of egress rules maps. Expected keys: from_port, to_port, protocol, cidr_blocks, description, security_groups, self"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
