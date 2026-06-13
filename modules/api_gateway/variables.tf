variable "name" { type = string }
variable "protocol" { type = string, default = "HTTP" }
variable "tags" { type = map(string), default = {} }
