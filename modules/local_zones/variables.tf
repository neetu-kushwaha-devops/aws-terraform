variable "name" {
  description = "The prefix to apply to resource names"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the Local Zone subnets will be created"
  type        = string
}

variable "subnets" {
  description = "Map of subnets to create in specific Local Zones. Key is subnet identifier, value is configuration."
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, false)
  }))
}

variable "route_table_id" {
  description = "Optionally associate the subnets with an existing Route Table"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
