terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ==========================================
# IAM Roles & Policies
# ==========================================

# EMR Service Role
resource "aws_iam_role" "emr_service" {
  count = var.create_service_role ? 1 : 0

  name                 = "${var.name}-emr-service-role"
  assume_role_policy   = data.aws_iam_policy_document.emr_service_assume[0].json
  permissions_boundary = var.service_role_permissions_boundary

  tags = merge(
    {
      Name = "${var.name}-emr-service-role"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "emr_service_assume" {
  count = var.create_service_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "emr_service" {
  count      = var.create_service_role ? 1 : 0
  role       = aws_iam_role.emr_service[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"
}

resource "aws_iam_role_policy_attachment" "emr_service_additional" {
  for_each   = var.create_service_role ? toset(var.service_role_additional_policies) : []
  role       = aws_iam_role.emr_service[0].name
  policy_arn = each.value
}

# EMR EC2 Instance Profile Role
resource "aws_iam_role" "emr_ec2" {
  count = var.create_instance_profile ? 1 : 0

  name                 = "${var.name}-emr-ec2-role"
  assume_role_policy   = data.aws_iam_policy_document.emr_ec2_assume[0].json
  permissions_boundary = var.instance_profile_role_permissions_boundary

  tags = merge(
    {
      Name = "${var.name}-emr-ec2-role"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "emr_ec2_assume" {
  count = var.create_instance_profile ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "emr_ec2" {
  count      = var.create_instance_profile ? 1 : 0
  role       = aws_iam_role.emr_ec2[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "emr_ec2_additional" {
  for_each   = var.create_instance_profile ? toset(var.instance_profile_additional_policies) : []
  role       = aws_iam_role.emr_ec2[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "emr_ec2" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${var.name}-emr-ec2-profile"
  role  = aws_iam_role.emr_ec2[0].name

  tags = merge(
    {
      Name = "${var.name}-emr-ec2-profile"
    },
    var.tags
  )
}

# ==========================================
# KMS Encryption Key
# ==========================================

resource "aws_kms_key" "emr" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "Customer Managed Key for EMR Cluster ${var.name} encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true

  policy = var.kms_key_policy != null ? var.kms_key_policy : data.aws_iam_policy_document.kms_emr[0].json

  tags = merge(
    {
      Name = "${var.name}-kms-key"
    },
    var.tags
  )
}

resource "aws_kms_alias" "emr" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.name}-kms-key"
  target_key_id = aws_kms_key.emr[0].key_id
}

data "aws_iam_policy_document" "kms_emr" {
  count = var.create_kms_key ? 1 : 0

  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow EMR Roles to use KMS Key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = compact([
        local.service_role_arn,
        local.instance_profile_role_arn
      ])
    }
  }

  statement {
    sid    = "Allow EMR Roles to create grants"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = compact([
        local.service_role_arn,
        local.instance_profile_role_arn
      ])
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

# Explicitly add KMS permissions from the role side as identity policy to avoid any evaluation boundary issues
resource "aws_iam_role_policy" "emr_service_kms" {
  count = var.create_service_role && (var.create_kms_key || var.kms_key_arn != null) ? 1 : 0
  name  = "${var.name}-emr-service-kms-policy"
  role  = aws_iam_role.emr_service[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = [local.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy" "emr_ec2_kms" {
  count = var.create_instance_profile && (var.create_kms_key || var.kms_key_arn != null) ? 1 : 0
  name  = "${var.name}-emr-ec2-kms-policy"
  role  = aws_iam_role.emr_ec2[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = [local.kms_key_arn]
      }
    ]
  })
}

# ==========================================
# EMR Security Groups
# ==========================================

resource "aws_security_group" "master" {
  count = var.create_security_groups ? 1 : 0

  name        = "${var.name}-emr-master-sg"
  description = "Security Group for EMR Master Node (managed by Terraform)"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  lifecycle {
    ignore_changes = [ingress, egress]
  }

  tags = merge(
    {
      Name = "${var.name}-emr-master-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "slave" {
  count = var.create_security_groups ? 1 : 0

  name        = "${var.name}-emr-slave-sg"
  description = "Security Group for EMR Slave Nodes (managed by Terraform)"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  lifecycle {
    ignore_changes = [ingress, egress]
  }

  tags = merge(
    {
      Name = "${var.name}-emr-slave-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "service_access" {
  count = var.create_security_groups && var.is_private_subnet ? 1 : 0

  name        = "${var.name}-emr-service-access-sg"
  description = "Security Group for EMR Service Access in Private Subnet (managed by Terraform)"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  lifecycle {
    ignore_changes = [ingress, egress]
  }

  tags = merge(
    {
      Name = "${var.name}-emr-service-access-sg"
    },
    var.tags
  )
}

# Outbound rules for EMR security groups to contact AWS endpoints
resource "aws_security_group_rule" "master_egress" {
  count             = var.create_security_groups ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master[0].id
}

resource "aws_security_group_rule" "slave_egress" {
  count             = var.create_security_groups ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.slave[0].id
}

resource "aws_security_group_rule" "service_access_egress" {
  count             = var.create_security_groups && var.is_private_subnet ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.service_access[0].id
}

# Secure Ingress SSH access from allowed CIDRs to Master Node
resource "aws_security_group_rule" "master_ssh" {
  count             = var.create_security_groups && var.key_name != null && length(var.ssh_allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_allowed_cidr_blocks
  security_group_id = aws_security_group.master[0].id
}

# ==========================================
# EMR Security Configuration
# ==========================================

resource "aws_emr_security_configuration" "this" {
  count = var.create_security_configuration ? 1 : 0

  name          = "${var.name}-security-config"
  configuration = var.security_configuration != null ? var.security_configuration : local.default_security_configuration
}

# ==========================================
# EMR Cluster
# ==========================================

resource "aws_emr_cluster" "this" {
  name          = var.name
  release_label = var.release_label
  applications  = var.applications
  service_role  = local.service_role_arn
  log_uri       = var.log_uri

  ec2_attributes {
    subnet_id                         = var.subnet_id
    key_name                          = var.key_name
    emr_managed_master_security_group = local.master_security_group_id
    emr_managed_slave_security_group  = local.slave_security_group_id
    service_access_security_group     = local.service_access_security_group_id
    instance_profile                  = var.create_instance_profile ? aws_iam_instance_profile.emr_ec2[0].arn : var.instance_profile_name_or_arn
  }

  security_configuration = var.create_security_configuration ? aws_emr_security_configuration.this[0].name : var.security_configuration_name

  master_instance_group {
    name           = "Master"
    instance_type  = var.master_instance_group.instance_type
    instance_count = var.master_instance_group.instance_count
    bid_price      = var.master_instance_group.bid_price

    dynamic "ebs_config" {
      for_each = var.master_instance_group.ebs_config != null ? var.master_instance_group.ebs_config : []
      content {
        size                 = ebs_config.value.size
        type                 = ebs_config.value.type
        volumes_per_instance = ebs_config.value.volumes_per_instance
        iops                 = ebs_config.value.iops
      }
    }
  }

  core_instance_group {
    name           = "Core"
    instance_type  = var.core_instance_group.instance_type
    instance_count = var.core_instance_group.instance_count
    bid_price      = var.core_instance_group.bid_price

    dynamic "ebs_config" {
      for_each = var.core_instance_group.ebs_config != null ? var.core_instance_group.ebs_config : []
      content {
        size                 = ebs_config.value.size
        type                 = ebs_config.value.type
        volumes_per_instance = ebs_config.value.volumes_per_instance
        iops                 = ebs_config.value.iops
      }
    }
  }

  dynamic "bootstrap_action" {
    for_each = var.bootstrap_actions
    content {
      name = bootstrap_action.value.name
      path = bootstrap_action.value.path
      args = bootstrap_action.value.args
    }
  }

  configurations_json               = var.configurations_json
  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps
  termination_protection            = var.termination_protection

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# ==========================================
# EMR Task Instance Groups (Dynamic / Optional)
# ==========================================

resource "aws_emr_instance_group" "task" {
  for_each = var.task_instance_groups

  cluster_id     = aws_emr_cluster.this.id
  name           = each.key
  instance_type  = each.value.instance_type
  instance_count = each.value.instance_count
  bid_price      = each.value.bid_price

  dynamic "ebs_config" {
    for_each = each.value.ebs_config != null ? each.value.ebs_config : []
    content {
      size                 = ebs_config.value.size
      type                 = ebs_config.value.type
      volumes_per_instance = ebs_config.value.volumes_per_instance
      iops                 = ebs_config.value.iops
    }
  }
}

# ==========================================
# Locals & Encryption Configurations
# ==========================================

locals {
  # Handle KMS key selection
  kms_key_arn = var.create_kms_key ? (length(aws_kms_key.emr) > 0 ? aws_kms_key.emr[0].arn : "") : var.kms_key_arn

  # Handle IAM Role Selection
  service_role_arn          = var.create_service_role ? (length(aws_iam_role.emr_service) > 0 ? aws_iam_role.emr_service[0].arn : "") : var.service_role_arn
  instance_profile_role_arn = var.create_instance_profile ? (length(aws_iam_role.emr_ec2) > 0 ? aws_iam_role.emr_ec2[0].arn : "") : var.instance_profile_role_arn

  # Handle Security Groups
  master_security_group_id         = var.emr_managed_master_security_group != null ? var.emr_managed_master_security_group : (var.create_security_groups && length(aws_security_group.master) > 0 ? aws_security_group.master[0].id : null)
  slave_security_group_id          = var.emr_managed_slave_security_group != null ? var.emr_managed_slave_security_group : (var.create_security_groups && length(aws_security_group.slave) > 0 ? aws_security_group.slave[0].id : null)
  service_access_security_group_id = var.is_private_subnet ? (var.service_access_security_group != null ? var.service_access_security_group : (var.create_security_groups && length(aws_security_group.service_access) > 0 ? aws_security_group.service_access[0].id : null)) : null

  # Dynamic Encryption Configuration Map
  encryption_config = merge(
    {
      EnableInTransitEncryption = var.enable_in_transit_encryption
      EnableAtRestEncryption    = var.enable_at_rest_encryption
    },
    var.enable_in_transit_encryption ? {
      InTransitEncryptionConfiguration = {
        TLSCertificateConfiguration = merge(
          {
            CertificateProviderType = var.in_transit_certificate_provider_type
          },
          var.in_transit_certificate_provider_type == "PEM" ? {
            S3Object = var.in_transit_certificate_s3_object
          } : {},
          var.in_transit_certificate_provider_type == "Custom" ? {
            S3Object                 = var.in_transit_certificate_s3_object
            CertificateProviderClass = var.in_transit_certificate_provider_class
          } : {}
        )
      }
    } : {},
    var.enable_at_rest_encryption ? {
      AtRestEncryptionConfiguration = {
        LocalDiskEncryptionConfiguration = {
          EnableEbsEncryption       = var.enable_ebs_encryption
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = local.kms_key_arn
        }
        S3EncryptionConfiguration = {
          EncryptionMode = var.s3_encryption_mode
          AwsKmsKey      = local.kms_key_arn
        }
      }
    } : {}
  )

  # Final security configuration JSON string
  default_security_configuration = jsonencode({
    EncryptionConfiguration = local.encryption_config
  })
}
