data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Parse S3 bucket names and convert to ARNs
  source_s3_bucket_arn = var.source_type == "S3" && var.source_location != null ? "arn:${data.aws_partition.current.partition}:s3:::${split("/", var.source_location)[0]}" : null
  artifacts_bucket_arn = var.artifacts_type == "S3" && var.artifacts_location != null ? "arn:${data.aws_partition.current.partition}:s3:::${var.artifacts_location}" : null
  cache_bucket_arn     = var.cache_type == "S3" && var.cache_location != null ? "arn:${data.aws_partition.current.partition}:s3:::${split("/", var.cache_location)[0]}" : null
  s3_logs_bucket_arn   = var.s3_logs_status == "ENABLED" && var.s3_logs_location != null ? "arn:${data.aws_partition.current.partition}:s3:::${split("/", var.s3_logs_location)[0]}" : null

  # Collect all S3 write/read bucket ARNs
  s3_all_write_arns = distinct(compact(concat(
    [local.artifacts_bucket_arn, local.cache_bucket_arn, local.s3_logs_bucket_arn],
    var.s3_write_arns
  )))

  s3_all_read_arns = distinct(compact(concat(
    [local.source_s3_bucket_arn],
    var.s3_read_arns
  )))

  # ECR permissions
  ecr_read_arns  = distinct(compact(var.ecr_read_arns))
  ecr_write_arns = distinct(compact(var.ecr_write_arns))

  # KMS permissions
  kms_key_arns = distinct(compact(concat(
    var.encryption_key != null ? [var.encryption_key] : [],
    var.kms_key_arns
  )))

  # CloudWatch log group settings
  cloudwatch_log_group_name = var.cloudwatch_logs_group_name != null ? var.cloudwatch_logs_group_name : "/aws/codebuild/${var.name}"
}

# IAM Role for CodeBuild Project
resource "aws_iam_role" "codebuild" {
  name                 = "${var.name}-codebuild-role"
  description          = "IAM service role for CodeBuild project ${var.name}"
  assume_role_policy   = data.aws_iam_policy_document.codebuild_assume_role.json
  permissions_boundary = null

  tags = merge(
    {
      Name = "${var.name}-codebuild-role"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

# IAM Policy with strict permissions mapping
resource "aws_iam_policy" "codebuild" {
  name        = "${var.name}-codebuild-policy"
  description = "IAM policy for CodeBuild project ${var.name}"
  policy      = data.aws_iam_policy_document.codebuild.json

  tags = merge(
    {
      Name = "${var.name}-codebuild-policy"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}

data "aws_iam_policy_document" "codebuild" {
  # 1. CloudWatch Logs
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}",
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}:*"
    ]
  }

  # 2. VPC permissions (conditional based on vpc_config existence)
  dynamic "statement" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      sid    = "VPCAccess"
      effect = "Allow"
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ]
      resources = ["*"]
    }
  }

  # 3. ECR permissions (conditional)
  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(local.ecr_read_arns) > 0 ? [1] : []
    content {
      sid    = "ECRRead"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
      resources = local.ecr_read_arns
    }
  }

  dynamic "statement" {
    for_each = length(local.ecr_write_arns) > 0 ? [1] : []
    content {
      sid    = "ECRWrite"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ]
      resources = local.ecr_write_arns
    }
  }

  # 4. S3 permissions
  dynamic "statement" {
    for_each = length(local.s3_all_read_arns) > 0 ? [1] : []
    content {
      sid    = "S3Read"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ]
      resources = concat(
        local.s3_all_read_arns,
        [for arn in local.s3_all_read_arns : "${arn}/*"]
      )
    }
  }

  dynamic "statement" {
    for_each = length(local.s3_all_write_arns) > 0 ? [1] : []
    content {
      sid    = "S3Write"
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:DeleteObject"
      ]
      resources = concat(
        local.s3_all_write_arns,
        [for arn in local.s3_all_write_arns : "${arn}/*"]
      )
    }
  }

  # 5. KMS permissions
  dynamic "statement" {
    for_each = length(local.kms_key_arns) > 0 ? [1] : []
    content {
      sid    = "KMSAccess"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
        "kms:DescribeKey"
      ]
      resources = local.kms_key_arns
    }
  }
}

# Optional CloudWatch Log Group for CodeBuild Build Logs
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_cloudwatch_log_group ? 1 : 0
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.cloudwatch_logs_kms_key_arn

  tags = merge(
    {
      Name = local.cloudwatch_log_group_name
    },
    var.tags
  )
}

# AWS CodeBuild Project
resource "aws_codebuild_project" "this" {
  name           = var.name
  description    = var.description
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = var.encryption_key

  artifacts {
    type                = var.artifacts_type
    location            = var.artifacts_type == "S3" ? var.artifacts_location : null
    path                = var.artifacts_type == "S3" ? var.artifacts_path : null
    namespace_type      = var.artifacts_type == "S3" ? var.artifacts_namespace_type : null
    packaging           = var.artifacts_type == "S3" ? var.artifacts_packaging : null
    encryption_disabled = var.artifacts_encryption_disabled
  }

  cache {
    type     = var.cache_type
    location = var.cache_type == "S3" ? var.cache_location : null
    modes    = var.cache_type == "LOCAL" ? var.cache_modes : null
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.build_image
    type                        = var.environment_type
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  source {
    type            = var.source_type
    location        = var.source_location
    buildspec       = var.buildspec
    git_clone_depth = var.git_clone_depth

    dynamic "git_submodules_config" {
      for_each = var.git_submodules_config != null ? [var.git_submodules_config] : []
      content {
        fetch_submodules = git_submodules_config.value.fetch_submodules
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  logs_config {
    cloudwatch_logs {
      status      = var.cloudwatch_logs_status
      group_name  = var.cloudwatch_logs_status == "ENABLED" ? local.cloudwatch_log_group_name : null
      stream_name = var.cloudwatch_logs_status == "ENABLED" ? var.cloudwatch_logs_stream_name : null
    }

    s3_logs {
      status              = var.s3_logs_status
      location            = var.s3_logs_status == "ENABLED" ? var.s3_logs_location : null
      encryption_disabled = var.s3_logs_encryption_disabled
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
