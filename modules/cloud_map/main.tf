resource "aws_service_discovery_http_namespace" "this" {
  count       = var.namespace_type == "HTTP" ? 1 : 0
  name        = var.name
  description = var.description

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  count       = var.namespace_type == "PRIVATE_DNS" ? 1 : 0
  name        = var.name
  description = var.description
  vpc         = var.vpc_id

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_service_discovery_public_dns_namespace" "this" {
  count       = var.namespace_type == "PUBLIC_DNS" ? 1 : 0
  name        = var.name
  description = var.description

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
