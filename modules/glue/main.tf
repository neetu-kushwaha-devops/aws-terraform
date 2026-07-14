terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_partition" "current" {}

# AWS Glue Module

locals {
  role_arn = var.create_role ? aws_iam_role.glue[0].arn : var.role_arn
}

#-------------------------------------------------------------------------------
# Glue Data Catalog Database
#-------------------------------------------------------------------------------
resource "aws_glue_catalog_database" "this" {
  name        = var.catalog_database_name != null ? var.catalog_database_name : "${var.name}_db"
  description = var.catalog_database_description
  parameters  = var.catalog_database_parameters

  tags = merge({ Name = var.name }, var.tags)
}

#-------------------------------------------------------------------------------
# Glue Data Catalog Encryption Settings
#-------------------------------------------------------------------------------
resource "aws_glue_data_catalog_encryption_settings" "this" {
  count = var.enable_catalog_encryption ? 1 : 0

  data_catalog_encryption_settings {
    connection_password_encryption {
      return_connection_password_encrypted = true
      aws_kms_key_id                       = var.kms_key_arn
    }

    encryption_at_rest {
      catalog_encryption_mode = var.kms_key_arn != null ? "SSE-KMS" : "DISABLED"
      sse_aws_kms_key_id      = var.kms_key_arn
    }
  }
}

#-------------------------------------------------------------------------------
# Glue Data Catalog Tables
#-------------------------------------------------------------------------------
resource "aws_glue_catalog_table" "this" {
  for_each = var.catalog_tables

  name          = each.key
  database_name = aws_glue_catalog_database.this.name
  catalog_id    = lookup(each.value, "catalog_id", null)
  description   = lookup(each.value, "description", null)
  owner         = lookup(each.value, "owner", null)
  retention     = lookup(each.value, "retention", null)
  table_type    = lookup(each.value, "table_type", "EXTERNAL_TABLE")
  parameters    = lookup(each.value, "parameters", {})

  dynamic "partition_keys" {
    for_each = lookup(each.value, "partition_keys", [])
    content {
      name    = partition_keys.value.name
      type    = partition_keys.value.type
      comment = lookup(partition_keys.value, "comment", null)
    }
  }

  dynamic "storage_descriptor" {
    for_each = lookup(each.value, "storage_descriptor", null) != null ? [each.value.storage_descriptor] : []
    content {
      location          = lookup(storage_descriptor.value, "location", null)
      input_format      = lookup(storage_descriptor.value, "input_format", null)
      output_format     = lookup(storage_descriptor.value, "output_format", null)
      compressed        = lookup(storage_descriptor.value, "compressed", null)
      number_of_buckets = lookup(storage_descriptor.value, "number_of_buckets", null)
      bucket_columns    = lookup(storage_descriptor.value, "bucket_columns", null)
      parameters        = lookup(storage_descriptor.value, "parameters", null)

      dynamic "columns" {
        for_each = lookup(storage_descriptor.value, "columns", [])
        content {
          name    = columns.value.name
          type    = columns.value.type
          comment = lookup(columns.value, "comment", null)
        }
      }

      dynamic "ser_de_info" {
        for_each = lookup(storage_descriptor.value, "serde_info", null) != null ? [storage_descriptor.value.serde_info] : []
        content {
          name                  = lookup(ser_de_info.value, "name", null)
          serialization_library = lookup(ser_de_info.value, "serialization_library", null)
          parameters            = lookup(ser_de_info.value, "parameters", null)
        }
      }

      dynamic "sort_columns" {
        for_each = lookup(storage_descriptor.value, "sort_columns", [])
        content {
          column     = sort_columns.value.column
          sort_order = sort_columns.value.sort_order
        }
      }

      dynamic "skewed_info" {
        for_each = lookup(storage_descriptor.value, "skewed_info", null) != null ? [storage_descriptor.value.skewed_info] : []
        content {
          skewed_column_names               = lookup(skewed_info.value, "skewed_column_names", null)
          skewed_column_values              = lookup(skewed_info.value, "skewed_column_values", null)
          skewed_column_value_location_maps = lookup(skewed_info.value, "skewed_column_value_location_maps", null)
        }
      }
    }
  }
}

#-------------------------------------------------------------------------------
# Glue Connection
#-------------------------------------------------------------------------------
resource "aws_glue_connection" "this" {
  for_each = var.connections

  name                  = each.key
  connection_type       = lookup(each.value, "connection_type", "JDBC")
  connection_properties = lookup(each.value, "connection_properties", {})
  description           = lookup(each.value, "description", null)
  catalog_id            = lookup(each.value, "catalog_id", null)
  match_criteria        = lookup(each.value, "match_criteria", null)

  dynamic "physical_connection_requirements" {
    for_each = lookup(each.value, "physical_connection_requirements", null) != null ? [each.value.physical_connection_requirements] : []
    content {
      availability_zone      = lookup(physical_connection_requirements.value, "availability_zone", null)
      security_group_id_list = lookup(physical_connection_requirements.value, "security_group_id_list", null)
      subnet_id              = lookup(physical_connection_requirements.value, "subnet_id", null)
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

#-------------------------------------------------------------------------------
# Glue Security Configuration
#-------------------------------------------------------------------------------
resource "aws_glue_security_configuration" "this" {
  name = var.security_configuration_name != null ? var.security_configuration_name : "${var.name}-security-config"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = var.kms_key_arn != null ? "SSE-KMS" : "DISABLED"
      kms_key_arn                = var.kms_key_arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = var.kms_key_arn != null ? "CSE-KMS" : "DISABLED"
      kms_key_arn                   = var.kms_key_arn
    }

    s3_encryption {
      s3_encryption_mode = var.kms_key_arn != null ? "SSE-KMS" : "SSE-S3"
      kms_key_arn        = var.kms_key_arn
    }
  }
}

#-------------------------------------------------------------------------------
# Glue Crawlers
#-------------------------------------------------------------------------------
resource "aws_glue_crawler" "this" {
  for_each = var.crawlers

  database_name          = aws_glue_catalog_database.this.name
  name                   = each.key
  role                   = local.role_arn
  description            = lookup(each.value, "description", null)
  classifiers            = lookup(each.value, "classifiers", null)
  configuration          = lookup(each.value, "configuration", null)
  schedule               = lookup(each.value, "schedule", null)
  security_configuration = aws_glue_security_configuration.this.name

  dynamic "s3_target" {
    for_each = lookup(each.value, "s3_target", [])
    content {
      path            = s3_target.value.path
      exclusions      = lookup(s3_target.value, "exclusions", null)
      connection_name = lookup(s3_target.value, "connection_name", null)
      sample_size     = lookup(s3_target.value, "sample_size", null)
    }
  }

  dynamic "dynamodb_target" {
    for_each = lookup(each.value, "dynamodb_target", [])
    content {
      path      = dynamodb_target.value.path
      scan_all  = lookup(dynamodb_target.value, "scan_all", null)
      scan_rate = lookup(dynamodb_target.value, "scan_rate", null)
    }
  }

  dynamic "jdbc_target" {
    for_each = lookup(each.value, "jdbc_target", [])
    content {
      connection_name = jdbc_target.value.connection_name
      path            = jdbc_target.value.path
      exclusions      = lookup(jdbc_target.value, "exclusions", null)
    }
  }

  dynamic "catalog_target" {
    for_each = lookup(each.value, "catalog_target", [])
    content {
      database_name = catalog_target.value.database_name
      tables        = catalog_target.value.tables
    }
  }

  dynamic "schema_change_policy" {
    for_each = lookup(each.value, "schema_change_policy", null) != null ? [each.value.schema_change_policy] : []
    content {
      delete_behavior = lookup(schema_change_policy.value, "delete_behavior", "DEPRECATE_IN_DATABASE")
      update_behavior = lookup(schema_change_policy.value, "update_behavior", "UPDATE_IN_DATABASE")
    }
  }

  dynamic "lineage_configuration" {
    for_each = lookup(each.value, "lineage_configuration", null) != null ? [each.value.lineage_configuration] : []
    content {
      crawler_lineage_settings = lookup(lineage_configuration.value, "crawler_lineage_settings", null)
    }
  }

  dynamic "lake_formation_configuration" {
    for_each = lookup(each.value, "lake_formation_configuration", null) != null ? [each.value.lake_formation_configuration] : []
    content {
      use_lake_formation_credentials = lookup(lake_formation_configuration.value, "use_lake_formation_credentials", null)
      account_id                     = lookup(lake_formation_configuration.value, "account_id", null)
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

#-------------------------------------------------------------------------------
# Glue Jobs
#-------------------------------------------------------------------------------
resource "aws_glue_job" "this" {
  for_each = var.jobs

  name                      = each.key
  role_arn                  = local.role_arn
  description               = lookup(each.value, "description", null)
  connections               = lookup(each.value, "connections", null)
  default_arguments         = lookup(each.value, "default_arguments", {})
  non_overridable_arguments = lookup(each.value, "non_overridable_arguments", {})
  max_retries               = lookup(each.value, "max_retries", 0)
  timeout                   = lookup(each.value, "timeout", 2880)
  security_configuration    = aws_glue_security_configuration.this.name
  glue_version              = lookup(each.value, "glue_version", "4.0")
  number_of_workers         = lookup(each.value, "number_of_workers", null)
  worker_type               = lookup(each.value, "worker_type", null)
  execution_class           = lookup(each.value, "execution_class", null)

  dynamic "command" {
    for_each = [each.value.command]
    content {
      name            = lookup(command.value, "name", "glueetl")
      script_location = command.value.script_location
      python_version  = lookup(command.value, "python_version", "3")
    }
  }

  dynamic "execution_property" {
    for_each = lookup(each.value, "execution_property", null) != null ? [each.value.execution_property] : []
    content {
      max_concurrent_runs = lookup(execution_property.value, "max_concurrent_runs", 1)
    }
  }

  dynamic "notification_property" {
    for_each = lookup(each.value, "notification_property", null) != null ? [each.value.notification_property] : []
    content {
      notify_delay_after = lookup(notification_property.value, "notify_delay_after", null)
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

#-------------------------------------------------------------------------------
# IAM Service Role & Policies
#-------------------------------------------------------------------------------
resource "aws_iam_role" "glue" {
  count = var.create_role ? 1 : 0

  name               = "${var.name}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role[0].json
  description        = "Service role for AWS Glue crawler and jobs"

  tags = merge({ Name = var.name }, var.tags)
}

data "aws_iam_policy_document" "glue_assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.glue[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "glue_s3" {
  count       = var.create_role && (length(var.s3_read_write_paths) > 0 || length(var.s3_read_only_paths) > 0 || var.kms_key_arn != null) ? 1 : 0
  name        = "${var.name}-glue-s3-policy"
  description = "Custom S3 and KMS permissions for Glue Crawler and Jobs"
  policy      = data.aws_iam_policy_document.glue_s3[0].json

  tags = merge({ Name = var.name }, var.tags)
}

data "aws_iam_policy_document" "glue_s3" {
  count = var.create_role && (length(var.s3_read_write_paths) > 0 || length(var.s3_read_only_paths) > 0 || var.kms_key_arn != null) ? 1 : 0

  dynamic "statement" {
    for_each = length(var.s3_read_write_paths) > 0 ? [1] : []
    content {
      sid    = "S3ReadWrite"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      resources = flatten([
        for path in var.s3_read_write_paths : [
          path,
          "${path}/*"
        ]
      ])
    }
  }

  dynamic "statement" {
    for_each = length(var.s3_read_only_paths) > 0 ? [1] : []
    content {
      sid    = "S3ReadOnly"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      resources = flatten([
        for path in var.s3_read_only_paths : [
          path,
          "${path}/*"
        ]
      ])
    }
  }

  dynamic "statement" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      sid    = "KMSAccess"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*",
        "kms:DescribeKey"
      ]
      resources = [var.kms_key_arn]
    }
  }
}

resource "aws_iam_role_policy_attachment" "glue_s3" {
  count      = var.create_role && (length(var.s3_read_write_paths) > 0 || length(var.s3_read_only_paths) > 0 || var.kms_key_arn != null) ? 1 : 0
  role       = aws_iam_role.glue[0].name
  policy_arn = aws_iam_policy.glue_s3[0].arn
}
