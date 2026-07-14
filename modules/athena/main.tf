terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Local variables to calculate values dynamically and enforce secure, clean defaults
locals {
  # Deduce the workgroup name
  workgroup_name = coalesce(var.workgroup_name, var.name)

  # strip s3:// prefix and any trailing slashes to get pure bucket name if they passed s3://bucket-name for raw bucket param
  s3_bucket_name = replace(replace(var.query_results_bucket, "s3://", ""), "/$", "")

  # Format output location properly as s3://bucket/path/
  s3_bucket_url = startswith(var.query_results_bucket, "s3://") ? var.query_results_bucket : "s3://${var.query_results_bucket}"

  # Ensure the output path ends with / if we have a prefix
  formatted_prefix = var.query_results_prefix != null ? (endswith(var.query_results_prefix, "/") ? var.query_results_prefix : "${var.query_results_prefix}/") : ""
  output_location  = "${local.s3_bucket_url}/${local.formatted_prefix}"

  # Default encryption option to SSE_KMS if kms_key_arn is set and encryption_option is null
  encryption_option = coalesce(var.encryption_option, var.kms_key_arn != null ? "SSE_KMS" : "SSE_S3")
}

resource "aws_athena_database" "this" {
  name          = var.database_name
  bucket        = local.s3_bucket_name
  force_destroy = var.database_force_destroy
  comment       = var.database_comment

  dynamic "encryption_configuration" {
    for_each = var.enable_database_encryption ? [1] : []
    content {
      encryption_option = local.encryption_option
      kms_key           = var.kms_key_arn
    }
  }
}

resource "aws_athena_workgroup" "this" {
  name        = local.workgroup_name
  description = var.workgroup_description
  state       = var.workgroup_state

  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query

    result_configuration {
      output_location = local.output_location

      encryption_configuration {
        encryption_option = local.encryption_option
        kms_key_arn       = var.kms_key_arn
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

resource "aws_athena_named_query" "this" {
  for_each = var.named_queries

  name        = coalesce(each.value.name, each.key)
  database    = coalesce(each.value.database, aws_athena_database.this.name)
  query       = each.value.query
  description = each.value.description
  workgroup   = aws_athena_workgroup.this.name
}
