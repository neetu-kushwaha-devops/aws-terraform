variable "name" { type = string }
variable "visibility_timeout_seconds" { type = number, default = 30 }
variable "tags" { type = map(string), default = {} }
