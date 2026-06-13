resource "aws_db_subnet_group" "this" {
  count       = var.db_subnet_group_name == null && length(var.subnet_ids) > 0 ? 1 : 0
  name        = "${var.name}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Database subnet group for ${var.name}"

  tags = merge(
    {
      Name = "${var.name}-subnet-group"
    },
    var.tags
  )
}

resource "aws_db_parameter_group" "this" {
  count  = var.create_parameter_group ? 1 : 0
  name   = var.parameter_group_name != null ? var.parameter_group_name : "${var.name}-pg"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    {
      Name = var.parameter_group_name != null ? var.parameter_group_name : "${var.name}-pg"
    },
    var.tags
  )
}

resource "aws_db_instance" "this" {
  identifier        = var.name
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  db_name           = var.db_name
  username          = var.username
  password          = var.password
  port              = var.port
  allocated_storage = var.allocated_storage

  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null

  multi_az               = var.multi_az
  db_subnet_group_name   = var.db_subnet_group_name != null ? var.db_subnet_group_name : (length(aws_db_subnet_group.this) > 0 ? aws_db_subnet_group.this[0].name : null)
  vpc_security_group_ids = var.vpc_security_group_ids

  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted ? var.kms_key_id : null

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.name}-final-snapshot")

  publicly_accessible = var.publicly_accessible

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
