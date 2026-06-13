output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = try(aws_guardduty_detector.this[0].id, null)
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector"
  value       = try(aws_guardduty_detector.this[0].arn, null)
}

output "publishing_destination_id" {
  description = "The ID of the GuardDuty publishing destination"
  value       = try(aws_guardduty_publishing_destination.this[0].id, null)
}
