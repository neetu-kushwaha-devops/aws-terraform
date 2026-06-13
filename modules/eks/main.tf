# KMS Key for EKS Envelope Encryption
resource "aws_kms_key" "eks" {
  count                   = var.create_kms_key && var.kms_key_arn == null ? 1 : 0
  description             = "EKS KMS Envelope Encryption Key for ${var.name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = merge({ Name = "${var.name}-kms" }, var.tags)
}

resource "aws_kms_alias" "eks" {
  count         = var.create_kms_key && var.kms_key_arn == null ? 1 : 0
  name          = "alias/eks/${var.name}"
  target_key_id = aws_kms_key.eks[0].key_id
}

locals {
  kms_key_arn = var.kms_key_arn != null ? var.kms_key_arn : (var.create_kms_key ? aws_kms_key.eks[0].arn : null)
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  count = var.create_cluster_role ? 1 : 0
  name  = "${var.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-cluster-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  count      = var.create_cluster_role ? 1 : 0
  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_controller" {
  count      = var.create_cluster_role ? 1 : 0
  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# CloudWatch Log Group for Control Plane Logs
resource "aws_cloudwatch_log_group" "eks" {
  count             = length(var.enabled_cluster_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 30
  tags              = merge({ Name = "${var.name}-logs" }, var.tags)
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.create_cluster_role ? aws_iam_role.cluster[0].arn : var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  dynamic "encryption_config" {
    for_each = local.kms_key_arn != null ? [1] : []
    content {
      provider {
        key_arn = local.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_vpc_controller,
    aws_cloudwatch_log_group.eks
  ]

  tags = merge({ Name = var.name }, var.tags)
}

# EKS Node Group IAM Role
resource "aws_iam_role" "node_group" {
  count = var.create_node_role ? 1 : 0
  name  = "${var.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-node-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_ssm" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom Launch Templates for Node Groups
resource "aws_launch_template" "this" {
  for_each = { for k, v in var.node_groups : k => v if lookup(v, "create_launch_template", false) }

  name = "${var.name}-${each.key}-node-lt"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(each.value, "disk_size", 30)
      volume_type           = lookup(each.value, "volume_type", "gp3")
      encrypted             = true
      kms_key_id            = local.kms_key_arn
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name}-${each.key}-node" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = "${var.name}-${each.key}-volume" })
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = 2
  }

  tags = merge({ Name = "${var.name}-${each.key}-lt" }, var.tags)
}

# EKS Managed Node Groups
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = var.create_node_role ? aws_iam_role.node_group[0].arn : each.value.node_role_arn
  subnet_ids      = lookup(each.value, "subnet_ids", var.subnet_ids)

  scaling_config {
    desired_size = lookup(each.value, "desired_size", 2)
    max_size     = lookup(each.value, "max_size", 4)
    min_size     = lookup(each.value, "min_size", 1)
  }

  update_config {
    max_unavailable = lookup(each.value, "max_unavailable", 1)
  }

  ami_type       = lookup(each.value, "ami_type", "AL2_x86_64")
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  instance_types = lookup(each.value, "instance_types", ["t3.medium"])

  # Use disk_size only if NOT using a launch template
  disk_size = lookup(each.value, "create_launch_template", false) ? null : lookup(each.value, "disk_size", 30)

  dynamic "launch_template" {
    for_each = lookup(each.value, "create_launch_template", false) ? [1] : (lookup(each.value, "launch_template_id", null) != null ? [1] : [])
    content {
      id      = lookup(each.value, "create_launch_template", false) ? aws_launch_template.this[each.key].id : each.value.launch_template_id
      version = lookup(each.value, "create_launch_template", false) ? aws_launch_template.this[each.key].latest_version : lookup(each.value, "launch_template_version", "$Latest")
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_ssm
  ]

  tags = merge({ Name = "${var.name}-${each.key}" }, var.tags)
}

# EKS Addons
resource "aws_eks_addon" "this" {
  for_each     = toset(var.addons)
  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  tags = merge({ Name = "${var.name}-${each.value}-addon" }, var.tags)

  depends_on = [
    aws_eks_node_group.this
  ]
}
