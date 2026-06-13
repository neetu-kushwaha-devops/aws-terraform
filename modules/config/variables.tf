variable "recorder_name" { type = string, default = null }
variable "delivery_s3_bucket" { type = string, default = null }
variable "rules" { type = list(any), default = [] }
variable "tags" { type = map(string), default = {} }
