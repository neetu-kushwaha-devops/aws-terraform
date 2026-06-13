variable "vpc_id" {
  description = "The VPC ID where the Internet Gateway will be created"
  type        = string
}

variable "name" {
  description = "Name tag for the Internet Gateway resource"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Internet Gateway"
  type        = map(string)
  default     = {}
}
