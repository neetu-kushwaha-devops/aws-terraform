# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "this" {
  name        = var.name
  description = var.application_description

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "this" {
  name                = var.name
  application         = aws_elastic_beanstalk_application.this.name
  description         = var.description
  tier                = var.tier
  solution_stack_name = var.solution_stack_name
  platform_arn        = var.platform_arn

  dynamic "setting" {
    for_each = local.merged_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# IAM Resources

# Data sources for trust policies
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["elasticbeanstalk"]
    }
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2" {
  count              = var.create_iam_resources ? 1 : 0
  name               = "${var.name}-eb-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    {
      Name = "${var.name}-eb-ec2-role"
    },
    var.tags
  )
}

# IAM Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_resources ? 1 : 0
  name  = "${var.name}-eb-instance-profile"
  role  = aws_iam_role.ec2[0].name

  tags = merge(
    {
      Name = "${var.name}-eb-instance-profile"
    },
    var.tags
  )
}

# IAM Service Role for Elastic Beanstalk Service
resource "aws_iam_role" "service" {
  count              = var.create_iam_resources ? 1 : 0
  name               = "${var.name}-eb-service-role"
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json

  tags = merge(
    {
      Name = "${var.name}-eb-service-role"
    },
    var.tags
  )
}

# Policy attachments for EC2 Role
resource "aws_iam_role_policy_attachment" "ec2" {
  for_each   = var.create_iam_resources ? toset(local.ec2_policies) : toset([])
  role       = aws_iam_role.ec2[0].name
  policy_arn = each.value
}

# Policy attachments for Service Role
resource "aws_iam_role_policy_attachment" "service" {
  for_each   = var.create_iam_resources ? toset(local.service_policies) : toset([])
  role       = aws_iam_role.service[0].name
  policy_arn = each.value
}

# Local variables for merging and styling settings
locals {
  instance_profile_name = var.create_iam_resources ? aws_iam_instance_profile.ec2[0].name : var.instance_profile_name
  service_role_arn      = var.create_iam_resources ? aws_iam_role.service[0].arn : var.service_role_arn

  ec2_policies = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  service_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth",
    "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
  ]

  # Standard defaults for Elastic Beanstalk environment settings
  default_settings_unfiltered = {
    "aws:elasticbeanstalk:cloudwatch:logs/StreamLogs" = {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "StreamLogs"
      value     = "true"
    }
    "aws:elasticbeanstalk:cloudwatch:logs/DeleteOnTerminate" = {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "DeleteOnTerminate"
      value     = "false" # Secure default: do not delete logs on terminate
    }
    "aws:elasticbeanstalk:cloudwatch:logs/RetentionInDays" = {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "RetentionInDays"
      value     = "30"
    }
    "aws:elasticbeanstalk:healthreporting:system/SystemType" = {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name      = "SystemType"
      value     = "enhanced"
    }
    "aws:elasticbeanstalk:managedactions/ManagedActionsEnabled" = {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "ManagedActionsEnabled"
      value     = "true"
    }
    "aws:elasticbeanstalk:managedactions:platformupdate/UpdateLevel" = {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name      = "UpdateLevel"
      value     = "patch"
    }
    "aws:elasticbeanstalk:managedactions:platformupdate/InstanceRefreshEnabled" = {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name      = "InstanceRefreshEnabled"
      value     = "true"
    }
    "aws:autoscaling:launchconfiguration/DisableIMDSv1" = {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "DisableIMDSv1"
      value     = "true" # Enforce IMDSv2
    }
    "aws:autoscaling:launchconfiguration/IamInstanceProfile" = local.instance_profile_name != null ? {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = local.instance_profile_name
    } : null
  }

  default_settings = {
    for k, v in local.default_settings_unfiltered : k => v if v != null
  }

  # Build common configuration settings
  common_settings = {
    "aws:autoscaling:launchconfiguration/InstanceType" = {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = var.instance_type
    }
    "aws:autoscaling:asg/MinSize" = {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value     = tostring(var.autoscale_min)
    }
    "aws:autoscaling:asg/MaxSize" = {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value     = tostring(var.autoscale_max)
    }
  }

  # Web server load balancer settings
  loadbalancer_settings = var.tier == "WebServer" ? {
    "aws:elasticbeanstalk:environment/LoadBalancerType" = {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "LoadBalancerType"
      value     = var.loadbalancer_type
    }
  } : {}

  # Service Role Settings
  service_role_settings = local.service_role_arn != null ? {
    "aws:elasticbeanstalk:environment/ServiceRole" = {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "ServiceRole"
      value     = local.service_role_arn
    }
    "aws:elasticbeanstalk:managedactions/ServiceRoleForManagedUpdates" = {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "ServiceRoleForManagedUpdates"
      value     = local.service_role_arn
    }
  } : {}

  # VPC Configuration Settings
  vpc_settings_unfiltered = var.vpc_id != null ? {
    "aws:ec2:vpc/VPCId" = {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = var.vpc_id
    }
    "aws:ec2:vpc/Subnets" = length(var.subnets) > 0 ? {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(",", var.subnets)
    } : null
    "aws:ec2:vpc/ELBSubnets" = length(var.elb_subnets) > 0 ? {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = join(",", var.elb_subnets)
    } : null
    "aws:ec2:vpc/ELBScheme" = {
      namespace = "aws:ec2:vpc"
      name      = "ELBScheme"
      value     = var.elb_scheme
    }
    "aws:ec2:vpc/AssociatePublicIpAddress" = {
      namespace = "aws:ec2:vpc"
      name      = "AssociatePublicIpAddress"
      value     = tostring(var.associate_public_ip_address)
    }
  } : {}

  vpc_settings = {
    for k, v in local.vpc_settings_unfiltered : k => v if v != null
  }

  # SSL listener settings for load balancer if certificate is provided
  ssl_settings = var.ssl_certificate_arn != null && var.tier == "WebServer" ? {
    "aws:elbv2:listener:443/ListenerEnabled" = {
      namespace = "aws:elbv2:listener:443"
      name      = "ListenerEnabled"
      value     = "true"
    }
    "aws:elbv2:listener:443/Protocol" = {
      namespace = "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = "HTTPS"
    }
    "aws:elbv2:listener:443/SSLCertificateArns" = {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.ssl_certificate_arn
    }
  } : {}

  # Convert environment properties map to setting format
  env_properties_map = {
    for k, v in var.environment_properties : "aws:elasticbeanstalk:application:environment/${k}" => {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = k
      value     = v
    }
  }

  # Convert overrides list to map keyed by namespace/name
  override_settings_map = {
    for s in var.setting_overrides : "${s.namespace}/${s.name}" => {
      namespace = s.namespace
      name      = s.name
      value     = s.value
      resource  = s.resource
    }
  }

  # Merge standard base configurations
  base_settings = merge(
    local.default_settings,
    local.common_settings,
    local.loadbalancer_settings,
    local.service_role_settings,
    local.vpc_settings,
    local.ssl_settings,
    local.env_properties_map
  )

  # Final merged settings with overrides taking precedence
  merged_settings = merge(
    local.base_settings,
    local.override_settings_map
  )
}
