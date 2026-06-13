variable "name" { type = string }
variable "subnets" { type = list(string) }
variable "tags" { type = map(string), default = {} }
