# Aurora Module

This module provisions an Amazon Aurora cluster with reader/writer instances, optional Serverless v2 scaling capacity, automated scaling for read replicas, backup retention policies, and security group integration.

## Usage Example

### 1. Provisioned Aurora PostgreSQL Cluster

```hcl
module "aurora" {
  source = "../modules/aurora"

  name            = "app-production-aurora"
  engine          = "aurora-postgresql"
  engine_version  = "15.4"
  cluster_size    = 2
  instance_class  = "db.r6g.large"
  database_name   = "productiondb"
  master_username = "superuser"
  master_password = "SuperSecurePassword123!" # Ideally fetched from Secrets Manager or KMS
  port            = 5432

  # Subnets & Security Groups
  subnet_ids             = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  vpc_security_group_ids = ["sg-0123456789abcdef2"]

  # Storage Encryption
  storage_encrypted = true

  # Auto Scaling for Read Replicas
  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 5
  autoscaling_target_cpu   = 70.0

  tags = {
    Environment = "production"
    Project     = "mlops"
  }
}
```

### 2. Aurora Serverless v2 Cluster

```hcl
module "aurora_serverless" {
  source = "../modules/aurora"

  name            = "app-dev-serverless"
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.04.0"
  cluster_size    = 2
  instance_class  = "db.serverless" # Required for Serverless v2
  database_name   = "devdb"
  master_username = "devadmin"
  master_password = "AnotherSecurePassword123!"

  subnet_ids             = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  vpc_security_group_ids = ["sg-0123456789abcdef2"]

  # Serverless v2 configuration
  enable_serverlessv2       = true
  serverlessv2_min_capacity = 0.5
  serverlessv2_max_capacity = 8.0

  tags = {
    Environment = "development"
    Project     = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name prefix for the Aurora cluster and related resources | `string` | n/a | yes |
| `engine` | The database engine to use | `string` | `"aurora-mysql"` | no |
| `engine_version` | The database engine version | `string` | `null` | no |
| `cluster_size` | Number of static cluster instances to create. If autoscaling is enabled, this acts as the base number of instances. | `number` | `2` | no |
| `instance_class` | The instance class to use. For Aurora Serverless v2, use `'db.serverless'` | `string` | `"db.t3.medium"` | no |
| `database_name` | The name of the initial database to create | `string` | `null` | no |
| `master_username` | Username for the master DB user | `string` | `"admin"` | no |
| `master_password` | Password for the master DB user (sensitive) | `string` | `null` | no |
| `port` | The port on which the DB accepts connections | `number` | `null` | no |
| `subnet_ids` | A list of VPC subnet IDs to create a DB subnet group | `list(string)` | `[]` | no |
| `db_subnet_group_name` | Existing DB subnet group name. If provided, subnet_ids is ignored. | `string` | `null` | no |
| `vpc_security_group_ids` | List of VPC security groups to associate with the cluster | `list(string)` | `[]` | no |
| `db_cluster_parameter_group_name` | The name of the DB cluster parameter group to associate with the cluster | `string` | `null` | no |
| `db_parameter_group_name` | The name of the DB parameter group to associate with the instances | `string` | `null` | no |
| `backup_retention_period` | The days to retain backups for. Must be between 1 and 35 | `number` | `7` | no |
| `preferred_backup_window` | The daily time range (in UTC) during which automated backups are created | `string` | `"03:00-04:00"` | no |
| `preferred_maintenance_window` | The window to perform maintenance in | `string` | `"Mon:04:00-Mon:05:00"` | no |
| `storage_encrypted` | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| `kms_key_id` | The ARN for the KMS key to use for cluster encryption | `string` | `null` | no |
| `deletion_protection` | If true, deletion protection will be enabled on the DB cluster | `bool` | `false` | no |
| `skip_final_snapshot` | Determines whether a final DB snapshot is created before the DB cluster is deleted | `bool` | `true` | no |
| `final_snapshot_identifier` | The name of the final snapshot of the DB cluster when deleted | `string` | `null` | no |
| `enable_serverlessv2` | Enables Aurora Serverless v2 configuration on the cluster | `bool` | `false` | no |
| `serverlessv2_min_capacity` | The minimum capacity for Aurora Serverless v2 in ACUs | `number` | `0.5` | no |
| `serverlessv2_max_capacity` | The maximum capacity for Aurora Serverless v2 in ACUs | `number` | `16.0` | no |
| `enable_autoscaling` | Enables Application Auto Scaling for Aurora read replicas | `bool` | `false` | no |
| `autoscaling_max_capacity` | The maximum number of reader replicas for auto scaling | `number` | `5` | no |
| `autoscaling_min_capacity` | The minimum number of reader replicas for auto scaling | `number` | `1` | no |
| `autoscaling_target_cpu` | The target CPU utilization (percentage) to trigger scaling | `number` | `70.0` | no |
| `autoscaling_scale_in_cooldown` | The cooldown period (seconds) before scaling in | `number` | `300` | no |
| `autoscaling_scale_out_cooldown` | The cooldown period (seconds) before scaling out | `number` | `300` | no |
| `publicly_accessible` | Bool to control if instances are publicly accessible | `bool` | `false` | no |
| `tags` | A map of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `aurora_cluster_id` | The ID of the Aurora cluster |
| `aurora_cluster_arn` | The ARN of the Aurora cluster |
| `aurora_cluster_endpoint` | The writer endpoint for the Aurora cluster |
| `aurora_cluster_reader_endpoint` | The reader endpoint for the Aurora cluster |
| `aurora_cluster_port` | The port of the Aurora cluster |
| `aurora_cluster_database_name` | The name of the database created |
| `aurora_cluster_master_username` | The master username for the database |
| `aurora_cluster_members` | List of RDS Instances that are members of the cluster |
| `db_subnet_group_name` | The subnet group name used by the cluster |
