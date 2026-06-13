variable "name" { type = string }
variable "s3_bucket_name" { type = string, default = null }
variable "is_multi_region_trail" { type = bool, default = true }
variable "tags" { type = map(string), default = {} }
