terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_lakeformation_data_lake_settings" "this" {
  count = (length(var.admins) > 0 || length(var.create_database_default_permissions) > 0 || length(var.create_table_default_permissions) > 0) ? 1 : 0

  catalog_id = var.settings_catalog_id
  admins     = length(var.admins) > 0 ? var.admins : null

  dynamic "create_database_default_permissions" {
    for_each = var.create_database_default_permissions
    content {
      permissions = create_database_default_permissions.value.permissions
      principal   = create_database_default_permissions.value.principal
    }
  }

  dynamic "create_table_default_permissions" {
    for_each = var.create_table_default_permissions
    content {
      permissions = create_table_default_permissions.value.permissions
      principal   = create_table_default_permissions.value.principal
    }
  }
}

resource "aws_lakeformation_resource" "this" {
  for_each = var.resources

  arn                     = each.value.arn
  role_arn                = each.value.role_arn
  use_service_linked_role = each.value.use_service_linked_role
  hybrid_access_enabled   = each.value.hybrid_access_enabled
}

resource "aws_lakeformation_lf_tag" "this" {
  for_each = var.lf_tags

  key        = each.key
  values     = each.value.values
  catalog_id = lookup(each.value, "catalog_id", null)
}

resource "aws_lakeformation_resource_lf_tags" "this" {
  for_each = var.lf_tag_relations

  dynamic "lf_tag" {
    for_each = [each.value.lf_tag]
    content {
      key        = lf_tag.value.key
      value      = lf_tag.value.value
      catalog_id = lookup(lf_tag.value, "catalog_id", null)
    }
  }

  dynamic "database" {
    for_each = lookup(each.value, "database", null) != null ? [each.value.database] : []
    content {
      name       = database.value.name
      catalog_id = lookup(database.value, "catalog_id", null)
    }
  }

  dynamic "table" {
    for_each = lookup(each.value, "table", null) != null ? [each.value.table] : []
    content {
      database_name = table.value.database_name
      name          = lookup(table.value, "name", null)
      wildcard      = lookup(table.value, "wildcard", null)
      catalog_id    = lookup(table.value, "catalog_id", null)
    }
  }

  dynamic "table_with_columns" {
    for_each = lookup(each.value, "table_with_columns", null) != null ? [each.value.table_with_columns] : []
    content {
      database_name = table_with_columns.value.database_name
      name          = table_with_columns.value.name
      column_names  = table_with_columns.value.column_names
      catalog_id    = lookup(table_with_columns.value, "catalog_id", null)
    }
  }
}

resource "aws_lakeformation_permissions" "this" {
  for_each = var.permissions

  principal                     = each.value.principal
  permissions                   = each.value.permissions
  permissions_with_grant_option = lookup(each.value, "permissions_with_grant_option", null)
  catalog_id                    = lookup(each.value, "catalog_id", null)

  dynamic "database" {
    for_each = lookup(each.value, "database", null) != null ? [each.value.database] : []
    content {
      name       = database.value.name
      catalog_id = lookup(database.value, "catalog_id", null)
    }
  }

  dynamic "table" {
    for_each = lookup(each.value, "table", null) != null ? [each.value.table] : []
    content {
      database_name = table.value.database_name
      name          = lookup(table.value, "name", null)
      wildcard      = lookup(table.value, "wildcard", null)
      catalog_id    = lookup(table.value, "catalog_id", null)
    }
  }

  dynamic "data_location" {
    for_each = lookup(each.value, "data_location", null) != null ? [each.value.data_location] : []
    content {
      arn        = data_location.value.arn
      catalog_id = lookup(data_location.value, "catalog_id", null)
    }
  }

  dynamic "lf_tag" {
    for_each = lookup(each.value, "lf_tag", null) != null ? [each.value.lf_tag] : []
    content {
      key        = lf_tag.value.key
      values     = lf_tag.value.values
      catalog_id = lookup(lf_tag.value, "catalog_id", null)
    }
  }

  dynamic "lf_tag_policy" {
    for_each = lookup(each.value, "lf_tag_policy", null) != null ? [each.value.lf_tag_policy] : []
    content {
      resource_type = lf_tag_policy.value.resource_type
      catalog_id    = lookup(lf_tag_policy.value, "catalog_id", null)

      dynamic "expression" {
        for_each = lf_tag_policy.value.expressions
        content {
          key    = expression.value.key
          values = expression.value.values
        }
      }
    }
  }

  dynamic "table_with_columns" {
    for_each = lookup(each.value, "table_with_columns", null) != null ? [each.value.table_with_columns] : []
    content {
      database_name         = table_with_columns.value.database_name
      name                  = table_with_columns.value.name
      column_names          = lookup(table_with_columns.value, "column_names", null)
      catalog_id            = lookup(table_with_columns.value, "catalog_id", null)
      wildcard              = lookup(table_with_columns.value, "wildcard", null)
      excluded_column_names = lookup(table_with_columns.value, "excluded_column_names", null)
    }
  }
}
