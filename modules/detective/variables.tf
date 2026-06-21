variable "enable" {
  description = "Enable the Detective Graph"
  type        = bool
  default     = true
}

variable "member_accounts" {
  description = "Map of AWS accounts to invite to the detective graph. Key is account ID, value is email address."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the Detective graph resources"
  type        = map(string)
  default     = {}
}
