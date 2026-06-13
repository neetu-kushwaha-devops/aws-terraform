variable "name" { type = string }
variable "enabled" { type = bool, default = true }
variable "aliases" { type = list(string), default = [] }
variable "tags" { type = map(string), default = {} }
