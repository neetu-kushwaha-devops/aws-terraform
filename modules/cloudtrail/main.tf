data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_cloudtrail" "this" {
  name                          = var.name
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  kms_key_id                    = var.kms_key_id
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
  include_global_service_events = var.include_global_service_events
  enable_logging                = var.enable_logging
  sns_topic_name                = var.sns_topic_name
  is_organization_trail         = var.is_organization_trail

  cloud_watch_logs_group_arn = var.create_cloudwatch_log_group ? "${aws_cloudwatch_log_group.this[0].arn}:*" : var.cloudwatch_logs_group_arn
  cloud_watch_logs_role_arn  = var.create_cloudwatch_log_group ? aws_iam_role.cloudtrail_cloudwatch[0].arn : var.cloudwatch_logs_role_arn

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      read_write_type           = lookup(event_selector.value, "read_write_type", "All")
      include_management_events = lookup(event_selector.value, "include_management_events", true)

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resources", [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  dynamic "insight_selector" {
    for_each = var.insight_selectors
    content {
      insight_type = insight_selector.value.insight_type
    }
  }

  tags = merge({ Name = var.name }, var.tags)

  depends_on = [
    aws_s3_bucket_policy.cloudtrail,
    aws_iam_role_policy.cloudtrail_cloudwatch
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_cloudwatch_log_group ? 1 : 0
  name              = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : "/aws/cloudtrail/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = merge({ Name = "${var.name}-logs" }, var.tags)
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  count = var.create_cloudwatch_log_group ? 1 : 0
  name  = "${var.name}-cloudtrail-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-role" }, var.tags)
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  count = var.create_cloudwatch_log_group ? 1 : 0
  name  = "${var.name}-cloudtrail-cw-policy"
  role  = aws_iam_role.cloudtrail_cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AWSCloudTrailCreateLogStream"
        Effect   = "Allow"
        Action   = "logs:CreateLogStream"
        Resource = "${aws_cloudwatch_log_group.this[0].arn}:*"
      },
      {
        Sid      = "AWSCloudTrailPutLogEvents"
        Effect   = "Allow"
        Action   = "logs:PutLogEvents"
        Resource = "${aws_cloudwatch_log_group.this[0].arn}:*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.attach_s3_bucket_policy ? 1 : 0
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/${var.s3_key_prefix != null ? "${var.s3_key_prefix}/" : ""}AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
