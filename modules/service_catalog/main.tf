resource "aws_servicecatalog_portfolio" "this" {
  name          = var.name
  provider_name = var.provider_name
  description   = var.description

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_servicecatalog_product" "this" {
  for_each = var.products

  name                = each.value.name
  owner               = each.value.owner
  type                = lookup(each.value, "type", "CLOUD_FORMATION_TEMPLATE")
  description         = lookup(each.value, "description", null)
  distributor         = lookup(each.value, "distributor", null)
  support_email       = lookup(each.value, "support_email", null)
  support_description = lookup(each.value, "support_description", null)
  support_url         = lookup(each.value, "support_url", null)

  dynamic "provisioning_artifact_parameters" {
    for_each = lookup(each.value, "provisioning_artifacts", [])
    content {
      name                        = provisioning_artifact_parameters.value.name
      description                 = lookup(provisioning_artifact_parameters.value, "description", null)
      template_url                = lookup(provisioning_artifact_parameters.value, "template_url", null)
      template_physical_id        = lookup(provisioning_artifact_parameters.value, "template_physical_id", null)
      type                        = lookup(provisioning_artifact_parameters.value, "type", "CLOUD_FORMATION_TEMPLATE")
      disable_template_validation = lookup(provisioning_artifact_parameters.value, "disable_template_validation", false)
    }
  }

  tags = merge(
    {
      Name = each.value.name
    },
    var.tags,
    lookup(each.value, "tags", {})
  )
}

resource "aws_servicecatalog_product_portfolio_association" "this" {
  for_each = aws_servicecatalog_product.this

  portfolio_id = aws_servicecatalog_portfolio.this.id
  product_id   = each.value.id
}

resource "aws_servicecatalog_product_portfolio_association" "external" {
  for_each = toset(var.additional_product_ids)

  portfolio_id = aws_servicecatalog_portfolio.this.id
  product_id   = each.value
}

resource "aws_servicecatalog_principal_portfolio_association" "this" {
  for_each = toset(var.principal_arns)

  portfolio_id   = aws_servicecatalog_portfolio.this.id
  principal_arn  = each.value
  principal_type = "IAM"
}

resource "aws_servicecatalog_constraint" "launch" {
  for_each = var.launch_constraints

  portfolio_id = aws_servicecatalog_portfolio.this.id
  product_id   = contains(keys(aws_servicecatalog_product.this), each.value.product_key) ? aws_servicecatalog_product.this[each.value.product_key].id : each.value.product_key
  type         = "LAUNCH"
  description  = lookup(each.value, "description", "Launch role constraint for ${each.value.product_key}")

  parameters = jsonencode({
    RoleArn = each.value.role_arn
  })
}
