output "portfolio_id" {
  description = "The ID of the Service Catalog Portfolio."
  value       = aws_servicecatalog_portfolio.this.id
}

output "portfolio_arn" {
  description = "The ARN of the Service Catalog Portfolio."
  value       = aws_servicecatalog_portfolio.this.arn
}

output "products_details" {
  description = "A map of created products and their details."
  value = {
    for k, v in aws_servicecatalog_product.this : k => {
      id           = v.id
      arn          = v.arn
      name         = v.name
      type         = v.type
      owner        = v.owner
      status       = v.status
      created_time = v.created_time
    }
  }
}
