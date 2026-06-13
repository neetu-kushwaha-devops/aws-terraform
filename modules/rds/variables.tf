variable "identifier" { type = string }
variable "engine" { type = string, default = "mysql" }
variable "instance_class" { type = string, default = "db.t3.micro" }
variable "username" { type = string }
variable "password" { type = string, sensitive = true }
variable "allocated_storage" { type = number, default = 20 }
variable "tags" { type = map(string), default = {} }
