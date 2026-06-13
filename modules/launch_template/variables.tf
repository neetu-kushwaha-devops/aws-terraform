variable "name" { type = string }
variable "ami" { type = string }
variable "instance_type" { type = string, default = "t3.micro" }
variable "tags" { type = map(string), default = {} }
