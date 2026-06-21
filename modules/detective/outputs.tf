output "graph_arn" {
  description = "The ARN of the Detective Graph"
  value       = one(aws_detective_graph.this[*].graph_arn)
}

output "graph_created" {
  description = "The creation date of the graph"
  value       = one(aws_detective_graph.this[*].created_time)
}
