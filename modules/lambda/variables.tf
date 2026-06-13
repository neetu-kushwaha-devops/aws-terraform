variable "name" { type = string }
variable "handler" { type = string, default = "handler.main" }
variable "runtime" { type = string, default = "python3.10" }
variable "role_arn" { type = string }
variable "filename" { type = string }
variable "tags" { type = map(string), default = {} }
