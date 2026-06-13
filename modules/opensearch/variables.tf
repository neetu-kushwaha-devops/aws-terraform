variable "domain_name" { type = string }
variable "instance_type" { type = string, default = "t3.small.search" }
variable "cluster_config" { type = map(any), default = {} }
variable "tags" { type = map(string), default = {} }
