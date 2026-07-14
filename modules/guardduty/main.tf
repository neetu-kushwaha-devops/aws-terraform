terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_guardduty_detector" "this" {
  count                        = var.enable ? 1 : 0
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_guardduty_detector_feature" "s3_protection" {
  count       = var.enable && var.enable_s3_protection ? 1 : 0
  detector_id = aws_guardduty_detector.this[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "malware_protection" {
  count       = var.enable && var.enable_malware_protection ? 1 : 0
  detector_id = aws_guardduty_detector.this[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

resource "aws_guardduty_publishing_destination" "this" {
  count            = var.enable && var.publishing_destination_arn != null && var.kms_key_arn != null ? 1 : 0
  detector_id      = aws_guardduty_detector.this[0].id
  destination_arn  = var.publishing_destination_arn
  kms_key_arn      = var.kms_key_arn
  destination_type = "S3"
}
