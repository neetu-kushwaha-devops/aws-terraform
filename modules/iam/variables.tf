variable "name" { type = string }
variable "assume_role_policy" { type = string, default = null }
variable "tags" { type = map(string), default = {} }
