output "assessment_id" {
  description = "The ID of the assessment"
  value       = aws_auditmanager_assessment.this.id
}

output "assessment_arn" {
  description = "The ARN of the assessment"
  value       = aws_auditmanager_assessment.this.arn
}

output "assessment_status" {
  description = "The status of the assessment"
  value       = aws_auditmanager_assessment.this.status
}
