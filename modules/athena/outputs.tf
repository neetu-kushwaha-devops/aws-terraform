output "database_id" {
  description = "The ID (name) of the Athena database"
  value       = aws_athena_database.this.id
}

output "database_name" {
  description = "The name of the Athena database"
  value       = aws_athena_database.this.name
}

output "workgroup_id" {
  description = "The ID of the Athena workgroup"
  value       = aws_athena_workgroup.this.id
}

output "workgroup_arn" {
  description = "The ARN of the Athena workgroup"
  value       = aws_athena_workgroup.this.arn
}

output "named_queries_details" {
  description = "Map of named queries created with their details"
  value = {
    for k, v in aws_athena_named_query.this : k => {
      id        = v.id
      name      = v.name
      database  = v.database
      workgroup = v.workgroup
      query     = v.query
    }
  }
}
