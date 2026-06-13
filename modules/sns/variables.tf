variable "name" { type = string }
variable "display_name" { type = string, default = null }
variable "tags" { type = map(string), default = {} }
