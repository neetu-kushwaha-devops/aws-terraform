resource "aws_fsx_lustre_file_system" "this" {
  storage_capacity            = var.storage_capacity
  subnet_ids                  = var.subnet_ids
  security_group_ids          = var.security_group_ids
  deployment_type             = var.deployment_type
  per_unit_storage_throughput = var.deployment_type != "SCRATCH_1" && var.deployment_type != "SCRATCH_2" ? var.per_unit_storage_throughput : null
  storage_type                = var.storage_type
  kms_key_id                  = var.kms_key_id

  # S3 Integration
  import_path              = var.import_path
  export_path              = var.export_path
  imported_file_chunk_size = var.imported_file_chunk_size
  auto_import_policy       = var.auto_import_policy

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
