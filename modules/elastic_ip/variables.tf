variable "name" {
  description = "Name prefix or base name for the Elastic IP resources"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "vpc" {
  description = "Boolean flag to determine if the Elastic IP is in a VPC. Sets domain to 'vpc' if true."
  type        = bool
  default     = true
}

variable "instance_id" {
  description = "EC2 instance ID to associate with the Elastic IP. Optional."
  type        = string
  default     = null
}

variable "network_interface_id" {
  description = "Network interface ID to associate with the Elastic IP. Optional."
  type        = string
  default     = null
}

variable "private_ip_address" {
  description = "Private IP address to associate with the Elastic IP. Requires network_interface_id or instance_id. Optional."
  type        = string
  default     = null
}

variable "count_eip" {
  description = "Number of Elastic IPs to create"
  type        = number
  default     = 1
}
