variable "name" { type = string }
variable "engine" { type = string, default = "aurora-mysql" }
variable "cluster_size" { type = number, default = 2 }
variable "tags" { type = map(string), default = {} }
