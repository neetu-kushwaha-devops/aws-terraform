data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  pipeline_role_arn = var.create_iam_role ? aws_iam_role.pipeline[0].arn : var.iam_role_arn
  kms_key_arn       = var.artifact_bucket_kms_key_arn != null ? var.artifact_bucket_kms_key_arn : aws_kms_key.artifacts[0].arn
}

# -----------------------------------------------------------------------------
# KMS Encryption Key for Artifact Bucket
# -----------------------------------------------------------------------------
resource "aws_kms_key" "artifacts" {
  count                   = var.artifact_bucket_kms_key_arn == null ? 1 : 0
  description             = "KMS key used to encrypt CodePipeline artifacts for ${var.name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy[0].json

  tags = merge(
    {
      Name = "${var.name}-kms-key"
    },
    var.tags
  )
}

resource "aws_kms_alias" "artifacts" {
  count         = var.artifact_bucket_kms_key_arn == null ? 1 : 0
  name          = "alias/codepipeline-${var.name}"
  target_key_id = aws_kms_key.artifacts[0].key_id
}

data "aws_iam_policy_document" "kms_key_policy" {
  count = var.artifact_bucket_kms_key_arn == null ? 1 : 0

  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow CodePipeline and IAM Role usage"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        # Grant access to the pipeline execution role
        var.create_iam_role ? aws_iam_role.pipeline[0].arn : var.iam_role_arn
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# S3 Artifact Store Bucket
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "artifacts" {
  bucket        = var.artifact_bucket_name
  bucket_prefix = var.artifact_bucket_name == null ? "${replace(lower(var.name), "/[^a-z0-9-]/", "")}-" : null
  force_destroy = var.artifact_bucket_force_destroy

  tags = merge(
    {
      Name = var.artifact_bucket_name != null ? var.artifact_bucket_name : "${var.name}-artifacts"
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  policy = data.aws_iam_policy_document.artifacts_bucket_policy.json
}

data "aws_iam_policy_document" "artifacts_bucket_policy" {
  statement {
    sid     = "EnforceTLSRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  count  = var.artifact_bucket_lifecycle_rules != null ? 1 : (var.artifact_bucket_expiration_days != null ? 1 : 0)
  bucket = aws_s3_bucket.artifacts.id

  dynamic "rule" {
    for_each = var.artifact_bucket_lifecycle_rules != null ? var.artifact_bucket_lifecycle_rules : (
      var.artifact_bucket_expiration_days != null ? [
        {
          id     = "cleanup-old-artifacts"
          status = "Enabled"
          expiration = {
            days = var.artifact_bucket_expiration_days
          }
          noncurrent_version_expiration = {
            noncurrent_days = var.artifact_bucket_expiration_days
          }
        }
      ] : []
    )

    content {
      id     = rule.value.id
      status = lookup(rule.value, "status", "Enabled")

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", null) != null ? [rule.value.expiration] : []
        content {
          days = lookup(expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration", null) != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# IAM Execution Role for CodePipeline
# -----------------------------------------------------------------------------
resource "aws_iam_role" "pipeline" {
  count              = var.create_iam_role ? 1 : 0
  name               = var.iam_role_name != null ? var.iam_role_name : "${var.name}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume_role[0].json
  path               = var.iam_role_path
  description        = "IAM Service Role for CodePipeline ${var.name}"

  tags = merge(
    {
      Name = var.iam_role_name != null ? var.iam_role_name : "${var.name}-pipeline-role"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "pipeline_assume_role" {
  count = var.create_iam_role ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "pipeline_policy" {
  count = var.create_iam_role ? 1 : 0

  statement {
    sid    = "S3ArtifactStoreAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }

  statement {
    sid    = "KMSKeyAccess"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*"
    ]
    resources = [local.kms_key_arn]
  }

  statement {
    sid    = "CodeStarConnectionsAccess"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodeBuildAccess"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "STSAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }

  # Allow dynamic custom statements if provided
  dynamic "statement" {
    for_each = var.custom_iam_policy_statements
    content {
      sid       = lookup(statement.value, "sid", null)
      effect    = lookup(statement.value, "effect", "Allow")
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "pipeline" {
  count  = var.create_iam_role ? 1 : 0
  name   = "${var.name}-pipeline-policy"
  role   = aws_iam_role.pipeline[0].id
  policy = data.aws_iam_policy_document.pipeline_policy[0].json
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each   = var.create_iam_role ? toset(var.iam_role_policy_arns) : []
  role       = aws_iam_role.pipeline[0].name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# AWS CodePipeline Resource
# -----------------------------------------------------------------------------
resource "aws_codepipeline" "this" {
  name          = var.name
  role_arn      = local.pipeline_role_arn
  pipeline_type = var.pipeline_type

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"

    encryption_key {
      id   = local.kms_key_arn
      type = "KMS"
    }
  }

  # Dynamic trigger configurations (V2 pipelines)
  dynamic "trigger" {
    for_each = var.triggers
    content {
      provider_type = trigger.value.provider_type

      dynamic "git_configuration" {
        for_each = lookup(trigger.value, "git_configuration", null) != null ? [trigger.value.git_configuration] : []
        content {
          source_action_name = git_configuration.value.source_action_name

          dynamic "push" {
            for_each = lookup(git_configuration.value, "push", [])
            content {
              dynamic "branches" {
                for_each = lookup(push.value, "branches", null) != null ? [push.value.branches] : []
                content {
                  includes = lookup(branches.value, "includes", null)
                  excludes = lookup(branches.value, "excludes", null)
                }
              }
              dynamic "tags" {
                for_each = lookup(push.value, "tags", null) != null ? [push.value.tags] : []
                content {
                  includes = lookup(tags.value, "includes", null)
                  excludes = lookup(tags.value, "excludes", null)
                }
              }
            }
          }
        }
      }
    }
  }

  # Dynamic stage configurations
  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          name             = action.value.name
          category         = action.value.category
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          run_order        = lookup(action.value, "run_order", null)
          input_artifacts  = lookup(action.value, "input_artifacts", [])
          output_artifacts = lookup(action.value, "output_artifacts", [])
          configuration    = lookup(action.value, "configuration", {})
          role_arn         = lookup(action.value, "role_arn", null)
          region           = lookup(action.value, "region", null)
        }
      }
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# CodePipeline Webhook Triggers
# -----------------------------------------------------------------------------
resource "aws_codepipeline_webhook" "this" {
  for_each        = { for idx, webhook in var.webhooks : webhook.name => webhook }
  name            = each.value.name
  authentication  = each.value.authentication
  target_action   = each.value.target_action
  target_pipeline = aws_codepipeline.this.name

  authentication_configuration {
    secret_token     = lookup(each.value.authentication_configuration, "secret_token", null)
    allowed_ip_range = lookup(each.value.authentication_configuration, "allowed_ip_range", null)
  }

  dynamic "filter" {
    for_each = each.value.filters
    content {
      json_path    = filter.value.json_path
      match_equals = filter.value.match_equals
    }
  }

  tags = merge(
    {
      Name = each.value.name
    },
    var.tags
  )
}
