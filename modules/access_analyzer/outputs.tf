output "analyzer_id" {
  description = "The name / ID of the analyzer"
  value       = aws_accessanalyzer_analyzer.this.id
}

output "analyzer_arn" {
  description = "The ARN of the analyzer"
  value       = aws_accessanalyzer_analyzer.this.arn
}
