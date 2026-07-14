# AWS Glue Module

This module provisions a production-ready, highly reusable AWS Glue environment. It includes support for Data Catalog Databases, Data Catalog Tables, Glue Crawlers, Glue Spark ETL/Python Shell Jobs, Glue Connections, and Glue Security Configurations. 

It enforces strict security defaults including Data Catalog encryption-at-rest, Job bookmark encryption, CloudWatch logs encryption, and secure, least-privilege IAM service execution roles.

## Features

- **Metadata Catalog**: Creates Glue Catalog Databases and dynamically defined Catalog Tables with nested schema/storage descriptors.
- **Data Catalog Security**: Configures AWS Glue Catalog encryption-at-rest and password encryption via KMS customer managed keys.
- **Custom Crawlers**: Dynamic setup of S3, DynamoDB, JDBC, and Catalog targets for schema crawlers.
- **ETL / Python Shell Jobs**: Configures Spark ETL (`glueetl`) and Python Shell (`pythonshell`) jobs with worker types, capacity management, and job bookmark encryption.
- **Glue Connections**: Configures VPC JDBC connections (including security group list and subnet configuration) for RDS or Redshift access.
- **Security-First Architecture**:
  - Encrypts job bookmarks and CloudWatch logs at rest.
  - Generates IAM roles following the principle of least privilege, restricting S3 path access to specified lists and mapping KMS key usage.

## Usage Example

```hcl
module "glue" {
  source = "../modules/glue"

  name        = "mlops-data-lake"
  kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/your-custom-kms-key-arn"

  # S3 paths the Glue job & crawler need permissions for
  s3_read_write_paths = [
    "arn:aws:s3:::mlops-processed-data",
    "arn:aws:s3:::mlops-glue-scripts"
  ]
  s3_read_only_paths = [
    "arn:aws:s3:::mlops-raw-landing"
  ]

  # Catalog Database name (defaults to name_db if not set)
  catalog_database_name = "mlops_analytics_db"

  # Catalog Tables definitions
  catalog_tables = {
    user_activity = {
      description = "Raw user activity logs"
      table_type  = "EXTERNAL_TABLE"
      parameters  = {
        classification = "parquet"
      }
      storage_descriptor = {
        location      = "s3://mlops-processed-data/user_activity/"
        input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
        serde_info = {
          name                  = "parquet-serde"
          serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
          parameters = {
            "serialization.format" = "1"
          }
        }
        columns = [
          { name = "user_id", type = "string", comment = "Unique identifier of the user" },
          { name = "event_time", type = "timestamp", comment = "Timestamp of event" },
          { name = "action", type = "string", comment = "Page view, click, purchase, etc." },
          { name = "device", type = "string", comment = "Device type" }
        ]
      }
      partition_keys = [
        { name = "year", type = "string" },
        { name = "month", type = "string" }
      ]
    }
  }

  # Crawlers definitions
  crawlers = {
    mlops-landing-crawler = {
      description   = "Crawls landing S3 bucket for schema discovery"
      schedule      = "cron(0 12 * * ? *)" # Everyday at 12 PM UTC
      s3_target = [
        {
          path = "s3://mlops-raw-landing/user_activity_raw/"
        }
      ]
      schema_change_policy = {
        delete_behavior = "DEPRECATE_IN_DATABASE"
        update_behavior = "UPDATE_IN_DATABASE"
      }
    }
  }

  # Glue Connections definitions (e.g. for Redshift/RDS access)
  connections = {
    redshift-connection = {
      connection_type = "JDBC"
      description     = "VPC Connection to MLOps Redshift Cluster"
      connection_properties = {
        JDBC_CONNECTION_URL = "jdbc:redshift://redshift-cluster.abcdefg.us-west-2.redshift.amazonaws.com:5439/dev"
        USERNAME            = "glue_etl_user"
        PASSWORD            = "SuperSecretPassword123!"
      }
      physical_connection_requirements = {
        availability_zone      = "us-west-2a"
        security_group_id_list = ["sg-12345678"]
        subnet_id              = "subnet-12345678"
      }
    }
  }

  # Spark ETL and Python Shell Jobs definitions
  jobs = {
    mlops-spark-etl-job = {
      description       = "Processes landing raw data into partitioned parquet output"
      glue_version      = "4.0"
      worker_type       = "G.1X"
      number_of_workers = 10
      timeout           = 120 # Minutes
      command = {
        name            = "glueetl"
        script_location = "s3://mlops-glue-scripts/scripts/spark_etl_user_activity.py"
        python_version  = "3"
      }
      default_arguments = {
        "--job-language"        = "python"
        "--TempDir"             = "s3://mlops-processed-data/temp/"
        "--enable-metrics"      = "true"
        "--enable-observability-metrics" = "true"
      }
    }
  }

  tags = {
    Environment = "production"
    Owner       = "mlops-team"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | A unique name to identify the resources, used as a prefix or base name | `string` | n/a | yes |
| `catalog_database_name` | The name of the Glue Catalog Database. If not specified, a default database name using var.name will be created | `string` | `null` | no |
| `catalog_database_description` | Description of the Glue Catalog Database | `string` | `"Glue Catalog Database managed by Terraform"` | no |
| `catalog_database_parameters` | A map of key-value pairs that defines parameters and properties of the database | `map(string)` | `{}` | no |
| `catalog_tables` | Map of catalog tables to create within the Glue Database | `map(object({...}))` | `{}` | no |
| `crawlers` | Map of Glue Crawlers to create. Keys are crawler names | `map(object({...}))` | `{}` | no |
| `jobs` | Map of Glue Jobs to create. Keys are job names | `map(object({...}))` | `{}` | no |
| `connections` | Map of Glue Connections to create. Keys are connection names | `map(object({...}))` | `{}` | no |
| `security_configuration_name` | Optional custom name for the Glue Security Configuration. If not provided, var.name-security-config will be used | `string` | `null` | no |
| `kms_key_arn` | The ARN of the KMS key used for encrypting Glue Data Catalog, CloudWatch Logs, Job Bookmarks, and S3 data | `string` | `null` | no |
| `enable_catalog_encryption` | Whether to enable encryption-at-rest for the Glue Data Catalog metadata | `bool` | `true` | no |
| `create_role` | Whether to create a new IAM service role for AWS Glue execution | `bool` | `true` | no |
| `role_arn` | The ARN of an existing IAM role to use for Glue execution. Required if `create_role` is false | `string` | `null` | no |
| `s3_read_write_paths` | List of S3 bucket paths/ARNs that the Glue service role should have read-write access to | `list(string)` | `[]` | no |
| `s3_read_only_paths` | List of S3 bucket paths/ARNs that the Glue service role should have read-only access to | `list(string)` | `[]` | no |
| `tags` | A map of tags to assign to the Glue resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `database_arn` | The ARN of the Glue Catalog Database |
| `database_name` | The name of the Glue Catalog Database |
| `crawlers_details` | Map of crawler details containing name and ARN |
| `jobs_details` | Map of job details containing name and ARN |
| `role_arn` | The ARN of the IAM role used for Glue execution |
| `security_configuration_name` | The name of the Glue Security Configuration |
