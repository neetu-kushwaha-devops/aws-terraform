variable "file_system_type" { type = string, default = "LUSTRE" }
variable "storage_capacity" { type = number, default = 1200 }
variable "tags" { type = map(string), default = {} }
