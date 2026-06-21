resource "aws_verifiedaccess_instance" "this" {
  description = var.description != null ? var.description : "${var.name} verified access instance"

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_verifiedaccess_trust_provider" "this" {
  for_each              = var.trust_providers
  policy_reference_name = each.value.policy_reference_name
  trust_provider_type   = each.value.trust_provider_type
  user_trust_provider_type = each.value.user_trust_provider_type

  dynamic "oidc_options" {
    for_each = each.value.oidc_options != null ? [each.value.oidc_options] : []
    content {
      authorization_endpoint = oidc_options.value.authorization_endpoint
      client_id              = oidc_options.value.client_id
      client_secret          = oidc_options.value.client_secret
      issuer                 = oidc_options.value.issuer
      scope                  = oidc_options.value.scope
      token_endpoint         = oidc_options.value.token_endpoint
      user_info_endpoint     = oidc_options.value.user_info_endpoint
    }
  }

  tags = merge(
    {
      Name = "${var.name}-trust-${each.key}"
    },
    var.tags
  )
}

resource "aws_verifiedaccess_instance_trust_provider_attachment" "this" {
  for_each                           = var.trust_providers
  verified_access_instance_id       = aws_verifiedaccess_instance.this.id
  verified_access_trust_provider_id = aws_verifiedaccess_trust_provider.this[each.key].id
}

resource "aws_verifiedaccess_group" "this" {
  for_each                    = var.groups
  verified_access_instance_id = aws_verifiedaccess_instance.this.id
  description                 = each.value.description
  policy_document             = each.value.policy_document

  tags = merge(
    {
      Name = "${var.name}-group-${each.key}"
    },
    var.tags
  )
}

resource "aws_verifiedaccess_endpoint" "this" {
  for_each                 = var.endpoints
  verified_access_group_id = aws_verifiedaccess_group.this[each.value.group_key].id
  application_domain       = each.value.application_domain
  endpoint_domain_prefix   = each.value.endpoint_domain_prefix
  endpoint_type            = each.value.endpoint_type
  domain_certificate_arn   = each.value.domain_certificate_arn
  security_group_ids       = each.value.security_group_ids

  dynamic "load_balancer_options" {
    for_each = each.value.load_balancer_options != null ? [each.value.load_balancer_options] : []
    content {
      load_balancer_arn = load_balancer_options.value.load_balancer_arn
      port              = load_balancer_options.value.port
      protocol          = load_balancer_options.value.protocol
      subnet_ids        = load_balancer_options.value.subnet_ids
    }
  }

  dynamic "network_interface_options" {
    for_each = each.value.network_interface_options != null ? [each.value.network_interface_options] : []
    content {
      network_interface_id = network_interface_options.value.network_interface_id
      port                 = network_interface_options.value.port
      protocol             = network_interface_options.value.protocol
    }
  }

  tags = merge(
    {
      Name = "${var.name}-ep-${each.key}"
    },
    var.tags
  )
}
