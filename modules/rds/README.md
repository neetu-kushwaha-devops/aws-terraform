# RDS Module

This module provisions an AWS Relational Database Service (RDS) instance with support for single or multi-AZ deployments, automatic storage scaling, parameter group configuration, KMS-based encryption at rest, subnet groups, and database backups.

## Usage Example

```hcl
module "rds" {
  source = "../modules/rds"

  name              = "app-production-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.medium"
  db_name           = "appdb"
  username          = "dbadmin"
  password          = "SuperSecretPassword123!" # Ideally fetched from Secrets Manager or KMS
  port              = 5432
  allocated_storage = 50
  
  # Storage Auto-scaling
  max_allocated_storage = 200

  # High Availability
  multi_az = true

  # Networking
  subnet_ids             = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  vpc_security_group_ids = ["sg-0123456789abcdef2"]

  # Parameter Group Config
  create_parameter_group = true
  parameter_group_family = "postgres15"
  parameters = [
    {
      name  = "log_connections"
      value = "1"
    },
    {
      name  = "log_disconnections"
      value = "1"
    }
  ]

  # Security & Backup
  storage_encrypted       = true
  backup_retention_period = 14
  deletion_protection     = true
  skip_final_snapshot     = false

  tags = {
    Environment = "production"
    Project     = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the RDS instance | `string` | n/a | yes |
| `engine` | The database engine to use | `string` | `"mysql"` | no |
| `engine_version` | The database engine version | `string` | `null` | no |
| `instance_class` | The instance type of the RDS instance | `string` | `"db.t3.micro"` | no |
| `db_name` | The name of the database to create when the DB instance is created | `string` | `null` | no |
| `username` | Username for the master DB user | `string` | n/a | yes |
| `password` | Password for the master DB user (sensitive) | `string` | n/a | yes |
| `port` | The port on which the DB accepts connections | `number` | `null` | no |
| `allocated_storage` | The allocated storage in gigabytes | `number` | `20` | no |
| `max_allocated_storage` | The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. (Storage autoscaling). Set to 0 to disable. | `number` | `100` | no |
| `multi_az` | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| `subnet_ids` | A list of VPC subnet IDs to create a DB subnet group | `list(string)` | `[]` | no |
| `db_subnet_group_name` | Existing DB subnet group name. If provided, subnet_ids is ignored. | `string` | `null` | no |
| `vpc_security_group_ids` | List of VPC security groups to associate with the RDS instance | `list(string)` | `[]` | no |
| `create_parameter_group` | Whether to create a new DB parameter group | `bool` | `false` | no |
| `parameter_group_name` | Existing DB parameter group name (used if create_parameter_group is false, or as a prefix if true) | `string` | `null` | no |
| `parameter_group_family` | The family of the DB parameter group | `string` | `"mysql8.0"` | no |
| `parameters` | A list of DB parameters (maps with name/value keys) to apply to the parameter group | `list(object)` | `[]` | no |
| `backup_retention_period` | The days to retain backups for. Must be between 0 and 35 | `number` | `7` | no |
| `backup_window` | The daily time range (in UTC) during which automated backups are created | `string` | `"03:00-04:00"` | no |
| `maintenance_window` | The window to perform maintenance in | `string` | `"Mon:04:00-Mon:05:00"` | no |
| `storage_encrypted` | Specifies whether the DB instance is encrypted | `bool` | `true` | no |
| `kms_key_id` | The ARN for the KMS key to use for database encryption | `string` | `null` | no |
| `deletion_protection` | The database can't be deleted when this value is set to true | `bool` | `false` | no |
| `skip_final_snapshot` | Determines whether a final DB snapshot is created before the DB instance is deleted | `bool` | `true` | no |
| `final_snapshot_identifier` | The name of the final snapshot of the DB instance when deleted | `string` | `null` | no |
| `publicly_accessible` | Bool to control if instance is publicly accessible | `bool` | `false` | no |
| `tags` | A map of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `db_instance_address` | The address of the RDS instance |
| `db_instance_arn` | The ARN of the RDS instance |
| `db_instance_endpoint` | The connection endpoint |
| `db_instance_id` | The RDS instance ID |
| `db_instance_resource_id` | The RDS instance resource ID |
| `db_instance_status` | The status of the RDS instance |
| `db_instance_port` | The database port |
| `db_subnet_group_name` | The subnet group name |
| `db_parameter_group_name` | The parameter group name |
