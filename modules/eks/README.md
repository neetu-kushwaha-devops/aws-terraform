# AWS EKS (Elastic Kubernetes Service) Module

This Terraform module provisions a production-grade Amazon EKS cluster with security best practices, including:
- EKS Cluster control plane logging
- KMS envelope encryption for Kubernetes secrets
- IAM roles for cluster and node groups with necessary least-privilege permissions
- Configurable private and public API endpoint access
- EKS Managed Node Groups with capacity type (ON_DEMAND/SPOT), scaling configurations, and custom launch templates using IMDSv2 and encrypted root volumes
- EKS addons (vpc-cni, coredns, kube-proxy)

## Usage

### 1. Basic EKS Cluster

```hcl
module "eks" {
  source = "./modules/eks"

  name            = "my-eks-cluster"
  cluster_version = "1.28"
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-111111", "subnet-222222", "subnet-333333"]

  tags = {
    Environment = "production"
  }
}
```

### 2. EKS Cluster with Custom Managed Node Groups (Spot & On-Demand mix)

```hcl
module "eks_custom" {
  source = "./modules/eks"

  name            = "production-cluster"
  cluster_version = "1.28"
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-111111", "subnet-222222", "subnet-333333"]

  # Security configurations
  endpoint_private_access = true
  endpoint_public_access  = false # Disable public endpoint for security
  create_kms_key          = true

  node_groups = {
    system = {
      desired_size           = 2
      max_size               = 3
      min_size               = 2
      instance_types         = ["t3.medium"]
      capacity_type          = "ON_DEMAND"
      create_launch_template = true
      disk_size              = 50
    }
    workloads = {
      desired_size           = 2
      max_size               = 10
      min_size               = 1
      instance_types         = ["c5.large", "c5d.large"]
      capacity_type          = "SPOT"
      create_launch_template = true
      disk_size              = 80
      volume_type            = "gp3"
    }
  }

  tags = {
    Environment = "production"
    Owner       = "devops-team"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the EKS cluster and prefix for related resources | `string` | n/a | yes |
| `cluster_version` | Desired Kubernetes master version | `string` | `"1.27"` | no |
| `vpc_id` | VPC ID where the EKS cluster and node groups will be deployed | `string` | n/a | yes |
| `subnet_ids` | A list of subnet IDs to associate with the EKS cluster and node groups | `list(string)` | `[]` | yes |
| `endpoint_private_access` | Indicates whether the Amazon EKS private API server endpoint is enabled | `bool` | `true` | no |
| `endpoint_public_access` | Indicates whether the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| `public_access_cidrs` | List of CIDR blocks that can access the Amazon EKS public API server endpoint | `list(string)` | `["0.0.0.0/0"]` | no |
| `create_kms_key` | Whether to create a new KMS key for cluster envelope encryption | `bool` | `true` | no |
| `kms_key_arn` | Existing KMS key ARN to use for cluster envelope encryption | `string` | `null` | no |
| `enabled_cluster_log_types` | A list of the desired control plane logging to enable | `list(string)` | `["api", "audit", "authenticator"]` | no |
| `addons` | List of EKS addons to install | `list(string)` | `["vpc-cni", "coredns", "kube-proxy"]` | no |
| `create_cluster_role` | Whether to create a default EKS cluster IAM role | `bool` | `true` | no |
| `cluster_role_arn` | ARN of an existing IAM role for EKS cluster. Used if `create_cluster_role` is false | `string` | `null` | no |
| `create_node_role` | Whether to create a default EKS node group IAM role | `bool` | `true` | no |
| `node_role_arn` | ARN of an existing IAM role for node groups. Used if `create_node_role` is false | `string` | `null` | no |
| `node_groups` | Map of EKS managed node group configurations. Keys are node group names | `any` | *(Default system group defined in variables)* | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The name/ID of the EKS cluster |
| `cluster_arn` | The ARN of the EKS cluster |
| `cluster_endpoint` | The endpoint for your EKS Kubernetes API server |
| `cluster_certificate_authority_data` | The base64 encoded certificate data required to communicate with your cluster |
| `cluster_security_group_id` | Security group ID created by the EKS cluster |
| `cluster_role_arn` | IAM role ARN of the EKS cluster |
| `node_group_role_arn` | IAM role ARN of the EKS node groups |
| `kms_key_arn` | KMS key ARN used for EKS cluster envelope encryption |
| `node_groups` | Outputs of the EKS Managed Node Groups |
