output "database_arn" {
  description = "The ARN of the Glue Catalog Database"
  value       = aws_glue_catalog_database.this.arn
}

output "database_name" {
  description = "The name of the Glue Catalog Database"
  value       = aws_glue_catalog_database.this.name
}

output "crawlers_details" {
  description = "Map of crawler details containing name and ARN"
  value = {
    for name, crawler in aws_glue_crawler.this : name => {
      arn  = crawler.arn
      name = crawler.name
    }
  }
}

output "jobs_details" {
  description = "Map of job details containing name and ARN"
  value = {
    for name, job in aws_glue_job.this : name => {
      arn  = job.arn
      name = job.name
    }
  }
}

output "role_arn" {
  description = "The ARN of the IAM role used for Glue execution"
  value       = local.role_arn
}

output "security_configuration_name" {
  description = "The name of the Glue Security Configuration"
  value       = aws_glue_security_configuration.this.name
}
