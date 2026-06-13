variable "name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "description" {
  description = "A short description of the CodeBuild project"
  type        = string
  default     = null
}

variable "build_timeout" {
  description = "Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait before timing out any builds that are not completed"
  type        = number
  default     = 60
}

variable "queued_timeout" {
  description = "Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out"
  type        = number
  default     = 480
}

variable "encryption_key" {
  description = "The AWS KMS customer master key (CMK) to be used for encrypting the build project's build output artifacts and logs. If not specified, the default AWS managed key is used"
  type        = string
  default     = null
}

variable "build_image" {
  description = "Docker image to use for the build environment"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "compute_type" {
  description = "Information about the compute resources the build project will use. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "environment_type" {
  description = "The type of build environment to use. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "privileged_mode" {
  description = "Whether to enable running the Docker daemon inside a Docker container"
  type        = bool
  default     = false
}

variable "image_pull_credentials_type" {
  description = "The type of credentials CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE_ROLE"
  type        = string
  default     = "CODEBUILD"
}

variable "environment_variables" {
  description = "A list of maps, each describing an environment variable for the build project"
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "vpc_config" {
  description = "VPC configuration for the CodeBuild project. If null, CodeBuild will run in non-VPC mode"
  type = object({
    vpc_id             = string
    subnets            = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "source_type" {
  description = "The type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, BITBUCKET, S3, NO_SOURCE"
  type        = string
  default     = "NO_SOURCE"
}

variable "source_location" {
  description = "The location of the source code (e.g. S3 bucket path, repository URL). If source_type is NO_SOURCE, this must be null"
  type        = string
  default     = null
}

variable "buildspec" {
  description = "The build spec declaration to use for the builds. Can be a path to a buildspec.yml file in the source, or the inline buildspec content itself"
  type        = string
  default     = null
}

variable "git_clone_depth" {
  description = "The truncate depth on a git clone"
  type        = number
  default     = null
}

variable "git_submodules_config" {
  description = "Information about git submodules configuration"
  type = object({
    fetch_submodules = bool
  })
  default = null
}

variable "artifacts_type" {
  description = "The build output artifact type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3"
  type        = string
  default     = "NO_ARTIFACTS"
}

variable "artifacts_location" {
  description = "Information about the build output artifact location. If S3, this is the name of the S3 bucket"
  type        = string
  default     = null
}

variable "artifacts_path" {
  description = "The path to the build output artifact in the location"
  type        = string
  default     = null
}

variable "artifacts_namespace_type" {
  description = "The organizational structure for build output artifacts. Valid values: NONE, BUILD_ID"
  type        = string
  default     = null
}

variable "artifacts_packaging" {
  description = "The type of packaging for build output artifacts. Valid values: NONE, ZIP"
  type        = string
  default     = null
}

variable "artifacts_encryption_disabled" {
  description = "Whether to disable encrypting build output artifacts. Default is false (encryption enabled for security)"
  type        = bool
  default     = false
}

variable "cache_type" {
  description = "The type of cache storage to use. Valid values: NO_CACHE, LOCAL, S3"
  type        = string
  default     = "NO_CACHE"
}

variable "cache_location" {
  description = "The location of the cache. For S3, this is the S3 bucket name and optional path"
  type        = string
  default     = null
}

variable "cache_modes" {
  description = "Specifies settings that CodeBuild uses to store and reuse cache. Valid values: LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE"
  type        = list(string)
  default     = null
}

variable "cloudwatch_logs_status" {
  description = "The status of CloudWatch logs. Valid values: ENABLED, DISABLED"
  type        = string
  default     = "ENABLED"
}

variable "cloudwatch_logs_stream_name" {
  description = "The name of the CloudWatch logs stream"
  type        = string
  default     = null
}

variable "s3_logs_status" {
  description = "The status of S3 logs. Valid values: ENABLED, DISABLED"
  type        = string
  default     = "DISABLED"
}

variable "s3_logs_location" {
  description = "The location of the S3 logs. Valid format is bucket-name/prefix"
  type        = string
  default     = null
}

variable "s3_logs_encryption_disabled" {
  description = "Whether to disable encrypting S3 logs. Default is false"
  type        = bool
  default     = false
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create a CloudWatch log group for CodeBuild logs"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_group_name" {
  description = "The name of the CloudWatch log group. If create_cloudwatch_log_group is true, this log group will be created with this name. If null, defaults to /aws/codebuild/<name>"
  type        = string
  default     = null
}

variable "cloudwatch_logs_retention_in_days" {
  description = "The number of days to retain log events in the specified log group"
  type        = number
  default     = 30
}

variable "cloudwatch_logs_kms_key_arn" {
  description = "The ARN of the KMS Key to use when encrypting log data"
  type        = string
  default     = null
}

variable "s3_read_arns" {
  description = "List of S3 bucket ARNs the CodeBuild project IAM role is allowed to read from"
  type        = list(string)
  default     = []
}

variable "s3_write_arns" {
  description = "List of S3 bucket ARNs the CodeBuild project IAM role is allowed to write to"
  type        = list(string)
  default     = []
}

variable "ecr_read_arns" {
  description = "List of ECR repository ARNs the CodeBuild project IAM role is allowed to pull from"
  type        = list(string)
  default     = []
}

variable "ecr_write_arns" {
  description = "List of ECR repository ARNs the CodeBuild project IAM role is allowed to push/pull from"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "List of additional KMS key ARNs that the CodeBuild project is allowed to use"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
