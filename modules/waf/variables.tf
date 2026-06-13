variable "name" { type = string }
variable "scope" { type = string, default = "REGIONAL" }
variable "rules" { type = list(any), default = [] }
variable "tags" { type = map(string), default = {} }
