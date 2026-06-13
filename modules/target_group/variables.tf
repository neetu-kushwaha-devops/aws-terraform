variable "name" { type = string }
variable "port" { type = number, default = 80 }
variable "protocol" { type = string, default = "HTTP" }
variable "vpc_id" { type = string }
variable "tags" { type = map(string), default = {} }
