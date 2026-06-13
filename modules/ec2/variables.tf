variable "name" {
  description = "Name for the EC2 instance and associated resources"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the instance"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch the instance in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "The key name to use for the instance. If create_key_pair is true, this is the name of the key pair to create."
  type        = string
  default     = null
}

variable "create_key_pair" {
  description = "Whether to create an aws_key_pair resource using the provided public_key"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "The public key material to use for the created key pair. Required if create_key_pair is true."
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile name to associate with the instance"
  type        = string
  default     = null
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "The base64-encoded user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "associate_eip" {
  description = "Whether to allocate and associate an Elastic IP (EIP) to the EC2 instance"
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root volume in gigabytes"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume (e.g. gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_delete_on_termination" {
  description = "Whether the root volume should be destroyed on instance termination"
  type        = bool
  default     = true
}

variable "root_encrypted" {
  description = "Whether the root volume should be encrypted"
  type        = bool
  default     = true
}

variable "root_kms_key_id" {
  description = "The ARN of the KMS Key to use for root volume encryption. root_encrypted must be true."
  type        = string
  default     = null
}

variable "root_iops" {
  description = "Amount of provisioned IOPS. Only valid for gp3, io1, and io2 volumes."
  type        = number
  default     = null
}

variable "root_throughput" {
  description = "Throughput to provision for a gp3 volume in MiB/s"
  type        = number
  default     = null
}

variable "ebs_block_device" {
  description = "List of maps containing additional EBS block device configurations to attach to the instance"
  type        = list(any)
  default     = []
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available (enabled or disabled)"
  type        = string
  default     = "enabled"
}

variable "metadata_http_tokens" {
  description = "Whether or not IMDSv2 is mandatory (required) or optional (optional)"
  type        = string
  default     = "required"
}

variable "metadata_http_put_response_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}

variable "metadata_instance_metadata_tags" {
  description = "Whether to enable access to instance tags from the metadata service (enabled or disabled)"
  type        = string
  default     = "disabled"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
