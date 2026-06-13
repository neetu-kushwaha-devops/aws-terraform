variable "name" { type = string }
variable "engine" { type = string, default = "redis" }
variable "node_type" { type = string, default = "cache.t3.micro" }
variable "replication_group" { type = bool, default = false }
variable "tags" { type = map(string), default = {} }
