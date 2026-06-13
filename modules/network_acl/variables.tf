variable "vpc_id" { type = string }
variable "entries" { type = list(map(string)), default = [] }
variable "tags" { type = map(string), default = {} }
