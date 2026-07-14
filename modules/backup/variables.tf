variable "name" {
  description = "Name for the resources"
  type        = string
}

variable "vault_name" {
  type        = string
  description = "Name of the AWS Backup vault to create"
}

variable "vault_kms_key_arn" {
  type        = string
  default     = null
  description = "The server-side encryption key (KMS Key ARN) that is used to protect your backups. If null, AWS Backup creates a default key for you"
}

variable "vault_policy" {
  type        = string
  default     = null
  description = "The IAM policy document in JSON format to apply to the AWS Backup vault"
}

variable "plan_name" {
  type        = string
  description = "Name of the AWS Backup plan to create"
}

variable "rules" {
  type = list(object({
    name              = string
    schedule          = optional(string, null)
    start_window      = optional(number, null)
    completion_window = optional(number, null)
    lifecycle = optional(object({
      cold_storage_after = optional(number, null)
      delete_after       = optional(number, null)
    }), null)
    recovery_point_tags = optional(map(string), null)
  }))
  default = [
    {
      name              = "daily-backup-rule"
      schedule          = "cron(0 12 * * ? *)" # daily at 12:00 PM UTC
      start_window      = 60
      completion_window = 120
      lifecycle = {
        cold_storage_after = null
        delete_after       = 30
      }
      recovery_point_tags = null
    }
  ]
  description = "List of backup rule objects. Each rule supports name, schedule, start_window, completion_window, recovery_point_tags, and lifecycle (cold_storage_after, delete_after) settings"
}

variable "create_iam_role" {
  type        = bool
  default     = true
  description = "Whether to create a new IAM role for AWS Backup. If false, iam_role_arn must be provided"
}

variable "iam_role_arn" {
  type        = string
  default     = null
  description = "The ARN of an existing IAM role to be used by AWS Backup if create_iam_role is false"
}

variable "selections" {
  type = map(object({
    name      = string
    resources = optional(list(string), null)
    selection_tags = optional(list(object({
      type  = string
      key   = string
      value = string
    })), [])
  }))
  default     = {}
  description = "Map of backup selections to apply. The key is a unique identifier, and the value is an object containing name, resources (list of ARNs), and selection_tags (list of objects with type, key, value)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}
