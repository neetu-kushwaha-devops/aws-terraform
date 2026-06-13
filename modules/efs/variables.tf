variable "performance_mode" { type = string, default = "generalPurpose" }
variable "throughput_mode" { type = string, default = "bursting" }
variable "tags" { type = map(string), default = {} }
