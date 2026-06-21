resource "aws_transfer_server" "this" {
  identity_provider_type = var.identity_provider_type
  protocols              = var.protocols
  endpoint_type          = var.endpoint_type

  dynamic "endpoint_details" {
    for_each = var.endpoint_type == "VPC" ? [1] : []
    content {
      vpc_id             = var.vpc_id
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_transfer_user" "this" {
  for_each       = var.users
  server_id      = aws_transfer_server.this.id
  user_name      = each.key
  role           = each.value.role_arn
  home_directory = each.value.home_directory != null ? each.value.home_directory : "/${each.value.s3_bucket_name}/${each.key}"

  tags = merge(
    {
      Name = "${var.name}-user-${each.key}"
    },
    var.tags
  )
}

resource "aws_transfer_ssh_key" "this" {
  for_each = {
    for k, v in var.users : k => v if v.ssh_public_key != null && v.ssh_public_key != ""
  }
  server_id = aws_transfer_server.this.id
  user_name = aws_transfer_user.this[each.key].user_name
  body      = each.value.ssh_public_key
}
