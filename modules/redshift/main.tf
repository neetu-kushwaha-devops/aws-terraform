terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Redshift Module

# Subnet Group Configuration
resource "aws_redshift_subnet_group" "this" {
  count = var.create_subnet_group ? 1 : 0

  name        = "${var.name}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for Redshift cluster ${var.name}"

  tags = merge({ Name = "${var.name}-subnet-group" }, var.tags)
}

# Redshift Cluster Configuration
resource "aws_redshift_cluster" "this" {
  cluster_identifier = var.name
  node_type          = var.node_type
  cluster_type       = var.cluster_type
  number_of_nodes    = var.cluster_type == "multi-node" ? var.number_of_nodes : null

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password
  port            = var.port

  vpc_security_group_ids    = var.vpc_security_group_ids
  cluster_subnet_group_name = var.create_subnet_group ? aws_redshift_subnet_group.this[0].name : var.cluster_subnet_group_name

  publicly_accessible  = var.publicly_accessible
  enhanced_vpc_routing = var.enhanced_vpc_routing

  # Encryption
  encrypted  = var.encrypted
  kms_key_id = var.encrypted ? var.kms_key_arn : null

  # IAM Roles
  iam_roles = var.iam_roles

  preferred_maintenance_window        = var.preferred_maintenance_window
  automated_snapshot_retention_period = var.automated_snapshot_retention_period
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  tags = merge({ Name = var.name }, var.tags)
}

# Redshift Logging Configuration
resource "aws_redshift_logging" "this" {
  count = var.logging_enabled ? 1 : 0

  cluster_identifier   = aws_redshift_cluster.this.id
  log_destination_type = "s3"
  bucket_name          = var.logging_bucket_name
  s3_key_prefix        = var.logging_s3_key_prefix
}
