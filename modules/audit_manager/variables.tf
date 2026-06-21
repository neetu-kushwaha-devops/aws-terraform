variable "name" {
  description = "The name of the assessment"
  type        = string
}

variable "framework_id" {
  description = "The ID of the custom or standard framework to use for the assessment"
  type        = string
}

variable "description" {
  description = "The description of the assessment"
  type        = string
  default     = null
}

variable "s3_destination" {
  description = "The S3 bucket destination for assessment reports (e.g. s3://my-audit-evidence-bucket)"
  type        = string
}

variable "roles" {
  description = "List of IAM roles to associate with the assessment"
  type = list(object({
    role_arn  = string
    role_type = string # e.g. PROCESS_OWNER
  }))
}

variable "scope" {
  description = "The scope of the assessment, detailing AWS accounts and services to audit"
  type = object({
    aws_accounts = optional(list(object({
      id = string
    })), [])
    aws_services = optional(list(object({
      name = string
    })), [])
  })
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
