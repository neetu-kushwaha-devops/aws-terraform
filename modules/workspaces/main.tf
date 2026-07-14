terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# AWS WorkSpaces Terraform Module - main.tf
# Provisions AWS WorkSpaces, registers directory, and configures IP access control groups.

# IP Access Control Group to restrict client access
resource "aws_workspaces_ip_group" "this" {
  count = length(var.ip_rules) > 0 ? 1 : 0

  name        = "${var.name}-ip-group"
  description = "IP access control group for WorkSpaces in ${var.name}"

  dynamic "rules" {
    for_each = var.ip_rules
    content {
      source      = rules.value.source
      description = rules.value.description
    }
  }

  tags = merge(
    {
      Name = "${var.name}-ip-group"
    },
    var.tags
  )
}

# WorkSpaces Directory Service Registration
resource "aws_workspaces_directory" "this" {
  count = var.register_directory ? 1 : 0

  directory_id = var.directory_id
  subnet_ids   = length(var.subnet_ids) > 0 ? var.subnet_ids : null

  ip_group_ids = length(var.ip_rules) > 0 ? [aws_workspaces_ip_group.this[0].id] : []

  self_service_permissions {
    change_compute_type  = var.self_service_change_compute_type
    increase_volume_size = var.self_service_increase_volume_size
    rebuild_workspace    = var.self_service_rebuild_workspace
    restart_workspace    = var.self_service_restart_workspace
    switch_running_mode  = var.self_service_switch_running_mode
  }

  workspace_access_properties {
    device_type_android    = var.device_type_android
    device_type_chromeos   = var.device_type_chromeos
    device_type_ios        = var.device_type_ios
    device_type_linux      = var.device_type_linux
    device_type_osx        = var.device_type_osx
    device_type_web        = var.device_type_web
    device_type_windows    = var.device_type_windows
    device_type_zeroclient = var.device_type_zeroclient
  }

  workspace_creation_properties {
    enable_internet_access              = var.enable_internet_access
    enable_maintenance_mode             = var.enable_maintenance_mode
    user_enabled_as_local_administrator = var.user_enabled_as_local_administrator
    default_ou                          = var.default_ou
    custom_security_group_id            = var.custom_security_group_id
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Optional Client Properties Configuration via AWS CLI local-exec
# Handles setting credentials caching (ReconnectEnabled) and diagnostic logging
resource "terraform_data" "client_properties" {
  count = var.register_directory && var.enable_client_properties_management ? 1 : 0

  triggers_replace = {
    directory_id       = aws_workspaces_directory.this[0].id
    reconnect_enabled  = var.reconnect_enabled
    log_upload_enabled = var.log_upload_enabled
  }

  provisioner "local-exec" {
    command = "aws workspaces modify-client-properties --resource-id ${aws_workspaces_directory.this[0].id} --client-properties ReconnectEnabled=${var.reconnect_enabled},LogUploadEnabled=${var.log_upload_enabled}"
  }
}

# AWS WorkSpaces instances
resource "aws_workspaces_workspace" "this" {
  for_each = { for ws in var.workspaces : ws.username => ws }

  # References directory registration resource to ensure it's registered first
  directory_id = var.register_directory ? aws_workspaces_directory.this[0].id : var.directory_id
  bundle_id    = each.value.bundle_id
  user_name    = each.value.username

  root_volume_encryption_enabled = each.value.volume_encryption
  user_volume_encryption_enabled = each.value.volume_encryption
  volume_encryption_key          = each.value.custom_kms_key_arn

  workspace_properties {
    compute_type_name                         = each.value.compute_type
    root_volume_size_gib                      = each.value.root_volume_size_gib
    user_volume_size_gib                      = each.value.user_volume_size_gib
    running_mode                              = each.value.running_mode
    running_mode_auto_stop_timeout_in_minutes = each.value.running_mode_auto_stop_timeout_in_minutes
  }

  tags = merge(
    {
      Name = "${var.name}-${each.value.username}"
    },
    var.tags,
    each.value.tags
  )
}
