variable "name" {
  description = "The prefix to apply to resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where endpoints will be created"
  type        = string
}

variable "gateway_endpoints" {
  description = "Map of gateway endpoints to create. Keys are service names (e.g. s3, dynamodb). Values configure route table IDs and policy."
  type = map(object({
    route_table_ids = optional(list(string), [])
    policy          = optional(string)
  }))
  default = {}
}

variable "interface_endpoints" {
  description = "Map of interface endpoints to create. Keys are service names (e.g. ecs, ecr.api). Values configure subnets, SGs, private DNS, and policy."
  type = map(object({
    subnet_ids          = list(string)
    security_group_ids  = list(string)
    private_dns_enabled = optional(bool, true)
    policy              = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
