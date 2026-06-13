variable "vpc_id" { type = string }
variable "routes" { type = list(map(string)), default = [] }
variable "tags" { type = map(string), default = {} }
