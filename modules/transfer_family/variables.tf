variable "name" {
  description = "The prefix to apply to resource names"
  type        = string
}

variable "identity_provider_type" {
  description = "The mode of authentication for a transfer server (SERVICE_MANAGED or API_GATEWAY)"
  type        = string
  default     = "SERVICE_MANAGED"
}

variable "protocols" {
  description = "The protocol(s) used by the transfer server (SFTP, FTP, FTPS)"
  type        = list(string)
  default     = ["SFTP"]
}

variable "endpoint_type" {
  description = "The type of endpoint. Can be PUBLIC, VPC, or VPC_ENDPOINT."
  type        = string
  default     = "PUBLIC"
}

variable "vpc_id" {
  description = "The VPC ID to associate with the transfer server. Required if endpoint_type is VPC."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "The subnets to deploy the transfer server. Required if endpoint_type is VPC."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "The security group IDs. Required if endpoint_type is VPC."
  type        = list(string)
  default     = []
}

variable "users" {
  description = "Map of Transfer users to provision. Keys are usernames, values specify role ARN, home directory S3 bucket, folder prefix, and SSH public key."
  type = map(object({
    role_arn       = string
    s3_bucket_name = string
    home_directory = optional(string)
    ssh_public_key = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
