terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  is_root = var.type == "ROOT"

  # S3 bucket configuration for CRL
  clean_name            = replace(lower(var.name), "_", "-")
  generated_bucket_name = "${local.clean_name}-crl-${data.aws_caller_identity.current.account_id}"
  crl_bucket_name       = var.enable_crl ? (var.crl_s3_bucket_name != null ? var.crl_s3_bucket_name : local.generated_bucket_name) : null
  create_crl_bucket     = var.enable_crl && var.crl_s3_bucket_name == null

  # CA Signer and Template
  signing_ca_arn       = local.is_root ? aws_acmpca_certificate_authority.this.arn : var.parent_certificate_authority_arn
  default_template_arn = local.is_root ? "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1" : "arn:${data.aws_partition.current.partition}:acm-pca:::template/SubordinateCACertificate_PathLen0/V1"
  template_arn         = var.template_arn != null ? var.template_arn : local.default_template_arn
}

# S3 Bucket for CRL (Optional)
resource "aws_s3_bucket" "crl" {
  count = local.create_crl_bucket ? 1 : 0

  bucket = local.crl_bucket_name

  tags = merge(
    {
      Name = "${var.name}-crl-bucket"
    },
    var.tags
  )
}

resource "aws_s3_bucket_ownership_controls" "crl" {
  count  = local.create_crl_bucket ? 1 : 0
  bucket = aws_s3_bucket.crl[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "crl" {
  count  = local.create_crl_bucket ? 1 : 0
  bucket = aws_s3_bucket.crl[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "crl" {
  count  = local.create_crl_bucket ? 1 : 0
  bucket = aws_s3_bucket.crl[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "crl" {
  count  = local.create_crl_bucket ? 1 : 0
  bucket = aws_s3_bucket.crl[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "crl_bucket_policy" {
  count = local.create_crl_bucket ? 1 : 0

  statement {
    sid    = "AllowACMPSAToWriteCRL"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["acm-pca.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.crl[0].arn,
      "${aws_s3_bucket.crl[0].arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "crl" {
  count  = local.create_crl_bucket ? 1 : 0
  bucket = aws_s3_bucket.crl[0].id
  policy = data.aws_iam_policy_document.crl_bucket_policy[0].json

  depends_on = [
    aws_s3_bucket_ownership_controls.crl,
    aws_s3_bucket_public_access_block.crl
  ]
}

# AWS Private Certificate Authority
resource "aws_acmpca_certificate_authority" "this" {
  type = var.type

  certificate_authority_configuration {
    key_algorithm     = var.key_algorithm
    signing_algorithm = var.signing_algorithm

    subject {
      common_name                  = var.subject.common_name
      organization                 = var.subject.organization
      organizational_unit          = var.subject.organizational_unit
      country                      = var.subject.country
      state                        = var.subject.state
      locality                     = var.subject.locality
      distinguished_name_qualifier = var.subject.distinguished_name_qualifier
      generation_qualifier         = var.subject.generation_qualifier
      given_name                   = var.subject.given_name
      initials                     = var.subject.initials
      pseudonym                    = var.subject.pseudonym
      surname                      = var.subject.surname
      title                        = var.subject.title
    }
  }

  dynamic "revocation_configuration" {
    for_each = var.enable_crl || var.enable_ocsp ? [1] : []
    content {
      dynamic "crl_configuration" {
        for_each = var.enable_crl ? [1] : []
        content {
          custom_cname       = var.crl_custom_cname
          enabled            = true
          expiration_in_days = var.crl_expiration_in_days
          s3_bucket_name     = local.crl_bucket_name
          s3_object_acl      = "BUCKET_OWNER_FULL_CONTROL"
        }
      }

      dynamic "ocsp_configuration" {
        for_each = var.enable_ocsp ? [1] : []
        content {
          enabled           = true
          ocsp_custom_cname = var.ocsp_custom_cname
        }
      }
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  depends_on = [
    aws_s3_bucket_policy.crl
  ]
}

# CA Activation: Certificate Generation
resource "aws_acmpca_certificate" "this" {
  certificate_authority_arn   = local.signing_ca_arn
  certificate_signing_request = aws_acmpca_certificate_authority.this.certificate_signing_request
  signing_algorithm           = var.signing_algorithm
  template_arn                = local.template_arn

  validity {
    type  = var.validity.type
    value = var.validity.value
  }
}

# CA Activation: Importing Certificate
resource "aws_acmpca_certificate_authority_certificate" "this" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn
  certificate               = aws_acmpca_certificate.this.certificate
  certificate_chain         = local.is_root ? null : aws_acmpca_certificate.this.certificate_chain
}

# CloudWatch Log Group for OCSP/CA logs (Optional)
resource "aws_cloudwatch_log_group" "ocsp" {
  count             = var.enable_ocsp && var.create_ocsp_log_group ? 1 : 0
  name              = "/aws/acmpca/${var.name}-ocsp"
  retention_in_days = var.ocsp_log_retention_in_days
  kms_key_id        = var.ocsp_log_group_kms_key_arn

  tags = merge(
    {
      Name = "${var.name}-ocsp-log-group"
    },
    var.tags
  )
}
