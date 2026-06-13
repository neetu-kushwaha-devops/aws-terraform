variable "name" { type = string }
variable "version" { type = string, default = "1.27" }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string), default = [] }
variable "tags" { type = map(string), default = {} }
