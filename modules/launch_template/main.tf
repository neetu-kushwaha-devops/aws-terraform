terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_launch_template" "this" {
  name          = var.use_name_prefix ? null : var.name
  name_prefix   = var.use_name_prefix ? "${var.name}-" : null
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data_base64

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null || var.iam_instance_profile_arn != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
      arn  = var.iam_instance_profile_arn
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) != null ? [block_device_mappings.value.ebs] : []
        content {
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", true)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          iops                  = lookup(ebs.value, "iops", null)
          throughput            = lookup(ebs.value, "throughput", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
        }
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_public_ip_address = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination       = lookup(network_interfaces.value, "delete_on_termination", null)
      description                 = lookup(network_interfaces.value, "description", null)
      device_index                = lookup(network_interfaces.value, "device_index", null)
      ipv4_address_count          = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv4_addresses              = lookup(network_interfaces.value, "ipv4_addresses", null)
      security_groups             = lookup(network_interfaces.value, "security_groups", null)
      subnet_id                   = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = var.name
      },
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name = var.name
      },
      var.tags
    )
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
