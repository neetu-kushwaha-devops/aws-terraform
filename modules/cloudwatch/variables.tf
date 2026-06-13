variable "log_group_name" { type = string, default = null }
variable "alarm_definitions" { type = list(any), default = [] }
variable "tags" { type = map(string), default = {} }
