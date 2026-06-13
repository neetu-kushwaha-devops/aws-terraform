variable "name" { type = string }
variable "description" { type = string, default = "" }
variable "vpc_id" { type = string }
variable "ingress" { type = list(map(string)), default = [] }
variable "egress" { type = list(map(string)), default = [] }
variable "tags" { type = map(string), default = {} }
