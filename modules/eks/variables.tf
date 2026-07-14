variable "name" {
  description = "Name of the EKS cluster and prefix for related resources"
  type        = string
}

variable "cluster_version" {
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster and node groups will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate with the EKS cluster and node groups"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_kms_key" {
  description = "Whether to create a new KMS key for cluster envelope encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN to use for cluster envelope encryption. If specified, create_kms_key is ignored"
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "addons" {
  description = "List of EKS addons to install"
  type        = list(string)
  default     = ["vpc-cni", "coredns", "kube-proxy"]
}

variable "create_cluster_role" {
  description = "Whether to create a default EKS cluster IAM role"
  type        = bool
  default     = true
}

variable "cluster_role_arn" {
  description = "ARN of an existing IAM role for EKS cluster. Used if create_cluster_role is false"
  type        = string
  default     = null
}

variable "create_node_role" {
  description = "Whether to create a default EKS node group IAM role"
  type        = bool
  default     = true
}

variable "node_role_arn" {
  description = "ARN of an existing IAM role for node groups. Used if create_node_role is false"
  type        = string
  default     = null
}

variable "node_groups" {
  description = "Map of EKS managed node group configurations. Keys are node group names"
  type = map(object({
    desired_size            = optional(number, 2)
    max_size                = optional(number, 4)
    min_size                = optional(number, 1)
    instance_types          = optional(list(string), ["t3.medium"])
    capacity_type           = optional(string, "ON_DEMAND")
    ami_type                = optional(string, "AL2_x86_64")
    create_launch_template  = optional(bool, false)
    disk_size               = optional(number, 30)
    volume_type             = optional(string, "gp3")
    max_unavailable         = optional(number, 1)
    subnet_ids              = optional(list(string), null)
    launch_template_id      = optional(string, null)
    launch_template_version = optional(string, "$Latest")
    node_role_arn           = optional(string, null)
  }))
  default = {
    default = {
      desired_size           = 2
      max_size               = 4
      min_size               = 1
      instance_types         = ["t3.medium"]
      capacity_type          = "ON_DEMAND"
      create_launch_template = true
      disk_size              = 30
      volume_type            = "gp3"
    }
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
