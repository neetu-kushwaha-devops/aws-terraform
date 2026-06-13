variable "name" { type = string }
variable "schedule_expression" { type = string, default = null }
variable "event_pattern" { type = string, default = null }
variable "tags" { type = map(string), default = {} }
