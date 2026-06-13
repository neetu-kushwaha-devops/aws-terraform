resource "aws_db_subnet_group" "this" {
  count       = var.db_subnet_group_name == null && length(var.subnet_ids) > 0 ? 1 : 0
  name        = "${var.name}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Database subnet group for Aurora cluster ${var.name}"

  tags = merge(
    {
      Name = "${var.name}-subnet-group"
    },
    var.tags
  )
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name
  engine             = var.engine
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password
  port               = var.port

  db_subnet_group_name            = var.db_subnet_group_name != null ? var.db_subnet_group_name : (length(aws_db_subnet_group.this) > 0 ? aws_db_subnet_group.this[0].name : null)
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted ? var.kms_key_id : null

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.name}-final-snapshot")

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.enable_serverlessv2 ? [1] : []
    content {
      min_capacity = var.serverlessv2_min_capacity
      max_capacity = var.serverlessv2_max_capacity
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_rds_cluster_instance" "this" {
  count              = var.cluster_size
  identifier         = "${var.name}-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  db_subnet_group_name    = aws_rds_cluster.this.db_subnet_group_name
  db_parameter_group_name = var.db_parameter_group_name
  publicly_accessible     = var.publicly_accessible

  tags = merge(
    {
      Name = "${var.name}-${count.index}"
    },
    var.tags
  )
}

# Auto Scaling for Read Replicas
resource "aws_appautoscaling_target" "read_replica" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${aws_rds_cluster.this.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "read_replica_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.name}-cpu-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_replica[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_replica[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_replica[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}
