variable "name" {
  description = "The prefix to apply to resource names"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the Wavelength resources will be created"
  type        = string
}

variable "subnets" {
  description = "Map of subnets to create in specific Wavelength Zones. Key is subnet identifier, value is configuration."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
