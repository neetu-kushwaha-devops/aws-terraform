variable "name" { type = string }
variable "cluster_settings" { type = map(any), default = {} }
variable "tags" { type = map(string), default = {} }
