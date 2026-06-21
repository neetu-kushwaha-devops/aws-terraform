output "cluster_arn" {
  description = "The ARN of the MSK cluster."
  value       = aws_msk_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the MSK cluster."
  value       = aws_msk_cluster.this.cluster_name
}

output "bootstrap_brokers" {
  description = "Comma separated list of one or more hostname:port pairs of Kafka brokers suitable to bootstrap the cluster (plaintext)."
  value       = aws_msk_cluster.this.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "Comma separated list of one or more TLS connection strings."
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_iam" {
  description = "Comma separated list of one or more IAM connection strings."
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
}

output "bootstrap_brokers_sasl_scram" {
  description = "Comma separated list of one or more SCRAM connection strings."
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "configuration_arn" {
  description = "The ARN of the MSK configuration (if created)."
  value       = length(aws_msk_configuration.this) > 0 ? aws_msk_configuration.this[0].arn : null
}

output "configuration_latest_revision" {
  description = "The latest revision of the MSK configuration (if created)."
  value       = length(aws_msk_configuration.this) > 0 ? aws_msk_configuration.this[0].latest_revision : null
}
