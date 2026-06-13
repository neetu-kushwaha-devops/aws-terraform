data "aws_region" "current" {}

resource "aws_securityhub_account" "this" {
  count = var.enable ? 1 : 0

  enable_default_standards  = var.enable_default_standards
  control_finding_generator = var.control_finding_generator
  auto_enable_controls      = var.auto_enable_controls
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count         = var.enable && var.enable_aws_foundational_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis" {
  count         = var.enable && var.enable_cis_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.region}::standards/cis-aws-foundations-benchmark/v/${var.cis_standard_version}"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "pci_dss" {
  count         = var.enable && var.enable_pci_dss_standard ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.region}::standards/pci-dss/v/${var.pci_dss_standard_version}"

  depends_on = [aws_securityhub_account.this]
}
