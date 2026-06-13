variable "name" {
  description = "The name used for tags and naming resources"
  type        = string
}

variable "repository_name" {
  description = "The name of the CodeCommit repository. If omitted, var.name will be used."
  type        = string
  default     = null
}

variable "description" {
  description = "The description of the CodeCommit repository"
  type        = string
  default     = null
}

variable "default_branch" {
  description = "The default branch of the repository. Note that the branch must already exist to be set as default."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to use for encrypting the repository. If not specified, the default AWS managed key aws/codecommit is used."
  type        = string
  default     = null
}

variable "triggers" {
  description = "List of repository triggers to configure"
  type = list(object({
    name            = string
    destination_arn = string
    events          = list(string)
    branches        = optional(list(string))
    custom_data     = optional(string)
  }))
  default = []
}

variable "lambda_trigger_permission_arns" {
  description = "List of Lambda function names or ARNs that should be permitted to be invoked by the CodeCommit repository triggers."
  type        = list(string)
  default     = []
}

variable "create_iam_policies" {
  description = "Whether to create standard IAM policies for accessing the repository"
  type        = bool
  default     = false
}

variable "iam_policy_path" {
  description = "Path for the generated IAM policies"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
