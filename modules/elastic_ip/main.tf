# Production-ready AWS Elastic IP (EIP) module
# Supports creating single or multiple EIPs and optionally associating them with EC2 instances or network interfaces

resource "aws_eip" "this" {
  count = var.count_eip

  domain = var.vpc ? "vpc" : null

  tags = merge(
    {
      Name = var.count_eip > 1 ? "${var.name}-${count.index}" : var.name
    },
    var.tags
  )
}

resource "aws_eip_association" "this" {
  count = (var.count_eip > 0 && (
    (var.instance_id != null && var.instance_id != "") ||
    (var.network_interface_id != null && var.network_interface_id != "")
  )) ? var.count_eip : 0

  allocation_id        = aws_eip.this[count.index].id
  instance_id          = var.instance_id != "" ? var.instance_id : null
  network_interface_id = var.network_interface_id != "" ? var.network_interface_id : null
  private_ip_address   = var.private_ip_address != "" ? var.private_ip_address : null
}
