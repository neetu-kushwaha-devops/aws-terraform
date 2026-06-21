terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = (var.validation_method == "NONE" || var.certificate_authority_arn != null) ? null : var.validation_method
  certificate_authority_arn = (var.validation_method == "NONE" || var.certificate_authority_arn != null) ? var.certificate_authority_arn : null

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = (var.validation_method == "DNS" && var.certificate_authority_arn == null && var.zone_id != null && var.zone_id != "") ? {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = (var.validate_certificate && (var.validation_method == "DNS" || var.validation_method == "EMAIL") && var.certificate_authority_arn == null) ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = (var.validation_method == "DNS" && var.zone_id != null && var.zone_id != "") ? [for record in aws_route53_record.validation : record.fqdn] : []
}
