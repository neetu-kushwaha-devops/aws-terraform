output "cluster_id" {
  description = "The name/ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID created by the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = try(aws_iam_role.cluster[0].arn, var.cluster_role_arn)
}

output "node_group_role_arn" {
  description = "IAM role ARN of the EKS node groups"
  value       = try(aws_iam_role.node_group[0].arn, var.node_role_arn)
}

output "kms_key_arn" {
  description = "KMS key ARN used for EKS cluster envelope encryption"
  value       = local.kms_key_arn
}

output "node_groups" {
  description = "Outputs of the EKS Managed Node Groups"
  value       = aws_eks_node_group.this
}
