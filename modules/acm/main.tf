resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  tags = merge({ Name = var.domain_name }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = (var.validation_method == "DNS" && (var.zone_id != "" || length(var.domain_to_zone_map) > 0)) ? {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = lookup(var.domain_to_zone_map, dvo.domain_name, var.zone_id)
    }
    if lookup(var.domain_to_zone_map, dvo.domain_name, var.zone_id) != ""
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = (var.validation_method == "DNS" && var.validate_certificate && (var.zone_id != "" || length(var.domain_to_zone_map) > 0)) ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
