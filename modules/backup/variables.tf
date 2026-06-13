variable "vault_name" { type = string }
variable "backup_plan" { type = map(any), default = {} }
variable "tags" { type = map(string), default = {} }
