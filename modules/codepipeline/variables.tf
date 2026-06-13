variable "name" {
  description = "The name of the AWS CodePipeline."
  type        = string
}

variable "artifact_bucket_name" {
  description = "The name of the S3 bucket to store artifacts. If omitted, the bucket name will be generated using the pipeline name as a prefix."
  type        = string
  default     = null
}

variable "artifact_bucket_kms_key_arn" {
  description = "The ARN of an existing KMS key to encrypt the artifact bucket. If omitted, a new customer-managed KMS key will be created."
  type        = string
  default     = null
}

variable "artifact_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the artifact bucket so that the bucket can be destroyed without error."
  type        = bool
  default     = false
}

variable "artifact_bucket_expiration_days" {
  description = "The number of days to keep artifacts before S3 automatically expires/deletes them. Set to null to disable expiration."
  type        = number
  default     = 30
}

variable "artifact_bucket_lifecycle_rules" {
  description = "A list of custom lifecycle rules to apply to the S3 artifact bucket. Overrides the default expiration rule if provided."
  type        = any
  default     = null
}

variable "stages" {
  description = "A list of stage configurations. Each stage contains a name and a list of actions."
  type = list(object({
    name = string
    actions = list(object({
      name             = string
      category         = string # Source, Build, Deploy, Test, Invoke, Approval
      owner            = string # AWS, ThirdParty, Custom
      provider         = string
      version          = string
      run_order        = optional(number)
      input_artifacts  = optional(list(string))
      output_artifacts = optional(list(string))
      configuration    = optional(map(string))
      role_arn         = optional(string)
      region           = optional(string)
    }))
  }))
}

variable "webhooks" {
  description = "A list of webhook configurations to trigger the pipeline."
  type = list(object({
    name           = string
    authentication = string # IP, GITHUB_HMAC, or UNAUTHENTICATED
    target_action  = string # The name of the action in the pipeline that is triggered by the webhook
    authentication_configuration = optional(object({
      secret_token     = optional(string)
      allowed_ip_range = optional(string)
    }), {})
    filters = list(object({
      json_path    = string
      match_equals = string
    }))
  }))
  default = []
}

variable "pipeline_type" {
  description = "The type of the pipeline. Valid values are V1 and V2. If omitted, the default provider value is used."
  type        = string
  default     = null
}

variable "triggers" {
  description = "Trigger configuration for the pipeline (supported in V2 pipelines)."
  type        = any
  default     = []
}

variable "create_iam_role" {
  description = "Whether to create a new IAM role for CodePipeline. If false, var.iam_role_arn must be provided."
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "The ARN of an existing IAM role to use for CodePipeline. Only used if var.create_iam_role is false."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "The name of the IAM role to create. If omitted, the name is generated using the pipeline name."
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "The path for the IAM role to create."
  type        = string
  default     = "/"
}

variable "custom_iam_policy_statements" {
  description = "A list of additional custom IAM policy statements to attach to the CodePipeline service role."
  type        = any
  default     = []
}

variable "iam_role_policy_arns" {
  description = "A list of IAM policy ARNs to attach to the CodePipeline service role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to all resources in this module."
  type        = map(string)
  default     = {}
}
