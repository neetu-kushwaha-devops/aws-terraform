variable "name" { type = string }
variable "launch_template" { type = map(any), default = {} }
variable "min_size" { type = number, default = 1 }
variable "max_size" { type = number, default = 1 }
variable "tags" { type = map(string), default = {} }
