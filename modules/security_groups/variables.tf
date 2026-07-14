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
  type = list(object({
    description      = optional(string, null)
    from_port        = optional(number, 0)
    to_port          = optional(number, 0)
    protocol         = optional(string, "-1")
    cidr_blocks      = optional(list(string), null)
    ipv6_cidr_blocks = optional(list(string), null)
    prefix_list_ids  = optional(list(string), null)
    security_groups  = optional(list(string), null)
    self             = optional(bool, null)
  }))
  description = "List of ingress rule objects. Use list(string) for cidr_blocks/ipv6_cidr_blocks/prefix_list_ids/security_groups."
  default     = []
}

variable "egress" {
  type = list(object({
    description      = optional(string, null)
    from_port        = optional(number, 0)
    to_port          = optional(number, 0)
    protocol         = optional(string, "-1")
    cidr_blocks      = optional(list(string), null)
    ipv6_cidr_blocks = optional(list(string), null)
    prefix_list_ids  = optional(list(string), null)
    security_groups  = optional(list(string), null)
    self             = optional(bool, null)
  }))
  description = "List of egress rule objects. Use list(string) for cidr_blocks/ipv6_cidr_blocks/prefix_list_ids/security_groups."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
