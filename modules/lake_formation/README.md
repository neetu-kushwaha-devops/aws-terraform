# AWS Lake Formation Terraform Module

This module provisions and manages AWS Lake Formation resources including data lake settings, registered S3 resources (locations), LF-tags, tag associations, and permissions (including Tag-Based Access Control - TBAC).

## Features

- **Data Lake Settings**: Manage global lake settings, register administrators, and revoke default database/table permissions (e.g., `IAMAllowedPrincipals`).
- **Resource Registration**: Register S3 data lake paths with Lake Formation using IAM roles or service-linked roles.
- **LF-Tags Management**: Define taxonomy tags (e.g., `Confidentiality = [High, Medium, Low]`) for metadata tagging.
- **Tag-Based Access Control (TBAC)**: Associate LF-tags with databases, tables, or table columns, and grant permissions via LF-tag policies to principals (users/roles).
- **Fine-Grained Permissions**: Grant database, table, column, and data location permissions directly or via wildcard configurations.

## Usage

### Complete Data Lake Setup with Tag-Based Access Control (TBAC)

This example registers an S3 data lake location, configures administrators, defines LF-tags, tags a Glue database/table, and grants fine-grained permissions to a role using LF-tag policy metadata access control.

```hcl
module "lake_formation" {
  source = "./modules/lake_formation"

  name = "analytics-lake"

  # 1. Register Data Lake Administrators & Disable Default IAM Permissions
  admins = [
    "arn:aws:iam::111122223333:role/DataLakeAdminRole",
    "arn:aws:iam::111122223333:user/admin-user"
  ]

  # Revoke default permissions for IAMAllowedPrincipals to enforce Lake Formation controls
  create_database_default_permissions = []
  create_table_default_permissions    = []

  # 2. Register S3 Data Lake Locations
  resources = {
    raw_s3_bucket = {
      arn                     = "arn:aws:s3:::my-analytics-data-lake-bucket"
      use_service_linked_role = true
    }
  }

  # 3. Define LF-Tags (Taxonomy)
  lf_tags = {
    Confidentiality = {
      values = ["Public", "Sensitive", "Restricted"]
    }
    Department = {
      values = ["Sales", "Finance", "Engineering"]
    }
  }

  # 4. Assign LF-Tags to Databases and Tables
  lf_tag_relations = {
    db_confidentiality = {
      lf_tag = {
        key   = "Confidentiality"
        value = "Sensitive"
      }
      database = {
        name = "sales_db"
      }
    }
    table_department = {
      lf_tag = {
        key   = "Department"
        value = "Sales"
      }
      table = {
        database_name = "sales_db"
        name          = "orders"
      }
    }
  }

  # 5. Grant Permissions using LF-Tag Policy (Metadata Access Control)
  permissions = {
    # Grant read access to the analyst role on resources tagged with Confidentiality = Sensitive
    analyst_tag_policy = {
      principal   = "arn:aws:iam::111122223333:role/DataAnalystRole"
      permissions = ["SELECT", "DESCRIBE"]

      lf_tag_policy = {
        resource_type = "TABLE"
        expressions = [
          {
            key    = "Confidentiality"
            values = ["Sensitive"]
          },
          {
            key    = "Department"
            values = ["Sales"]
          }
        ]
      }
    }

    # Grant Data Location access to Glue Service Role for S3 registrations
    glue_location_access = {
      principal   = "arn:aws:iam::111122223333:role/AWSGlueServiceRole"
      permissions = ["DATA_LOCATION_ACCESS"]
      
      data_location = {
        arn = "arn:aws:s3:::my-analytics-data-lake-bucket"
      }
    }
  }

  tags = {
    Environment = "production"
    Team        = "DataPlatform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix to be used for resources and tagging. | `string` | `""` | no |
| `tags` | A mapping of tags to assign to resources. | `map(string)` | `{}` | no |
| `admins` | List of ARNs of AWS IAM users or roles to set as Lake Formation administrators. | `set(string)` | `[]` | no |
| `settings_catalog_id` | Identifier for the Data Catalog. If not provided, the account ID is used. | `string` | `null` | no |
| `create_database_default_permissions` | Up to 3 default permissions for newly created databases. Typically empty to revoke default permissions. | `list(object)` | `[]` | no |
| `create_table_default_permissions` | Up to 3 default permissions for newly created tables. Typically empty to revoke default permissions. | `list(object)` | `[]` | no |
| `resources` | Map of S3 locations or databases to register with Lake Formation. | `map(object)` | `{}` | no |
| `permissions` | Map of permissions to grant to principals on various Lake Formation resources. Supports Database, Table, Data Location, LF-Tag, and LF-Tag Policy configurations. | `map(object)` | `{}` | no |
| `lf_tags` | Map of LF-tags to create. The key is the tag key. | `map(object)` | `{}` | no |
| `lf_tag_relations` | Map of LF-tag relations to assign LF-tags to specific catalog resources. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `settings_id` | The ID of the Lake Formation data lake settings. |
| `resources_arns` | Map of registered Lake Formation resource keys to their ARNs. |
| `lf_tags_names` | List of the keys of the LF-tags created. |
| `permissions_ids` | Map of permission keys to their generated permission resource IDs. |
| `lf_tag_relations_ids` | Map of LF-tag relation keys to their relation resource IDs. |
