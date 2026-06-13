variable "name" { type = string }
variable "role_arn" { type = string }
variable "definition" { type = string }
variable "tags" { type = map(string), default = {} }
