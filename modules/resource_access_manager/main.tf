resource "aws_ram_resource_share" "this" {
  name                      = var.name
  allow_external_principals = var.allow_external_principals

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_ram_principal_association" "this" {
  count              = length(var.principals)
  principal          = var.principals[count.index]
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ram_resource_association" "this" {
  count              = length(var.resources)
  resource_arn       = var.resources[count.index]
  resource_share_arn = aws_ram_resource_share.this.arn
}
