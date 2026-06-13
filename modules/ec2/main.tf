resource "aws_key_pair" "this" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name != null ? var.key_name : var.name
  public_key = var.public_key
  tags = merge(
    {
      Name = var.key_name != null ? var.key_name : var.name
    },
    var.tags
  )
}

resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.root_encrypted
    kms_key_id            = var.root_kms_key_id
    iops                  = var.root_iops
    throughput            = var.root_throughput
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_eip" "this" {
  count    = var.associate_eip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(
    {
      Name = "${var.name}-eip"
    },
    var.tags
  )
}
