variable "bucket" { type = string }
variable "acl" { type = string, default = "private" }
variable "versioning" { type = bool, default = false }
variable "tags" { type = map(string), default = {} }
