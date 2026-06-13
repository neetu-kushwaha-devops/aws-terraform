variable "name" { type = string }
variable "node_type" { type = string, default = "dc2.large" }
variable "cluster_type" { type = string, default = "single-node" }
variable "tags" { type = map(string), default = {} }
