variable "name" { type = string }
variable "protection_type" { type = string, default = "STANDARD" }
variable "tags" { type = map(string), default = {} }
