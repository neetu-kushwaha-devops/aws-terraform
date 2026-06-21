# AWS Elastic Beanstalk Terraform Module

This module provisions an AWS Elastic Beanstalk application and environment configured with production-ready features and secure defaults (e.g., IMDSv2 enforcement, CloudWatch log streaming with retention, and automated patch updates).

## Features

- **IAM Automation**: Optionally provisions necessary service roles and EC2 instance profiles with standard permissions.
- **Secure Defaults**:
  - Enforces **IMDSv2** (disables IMDSv1) for EC2 instances.
  - Automatically configures **CloudWatch log streaming** with configurable retention (defaults to 30 days) and prevents log deletion upon environment termination.
  - Enables **Enhanced Health** reporting.
  - Automatically enables **Managed Actions** and schedules automated patch platform updates.
- **VPC Integration**: Easily deploys Elastic Beanstalk to a custom VPC with options for public/internal load balancer schemes, subnets, and public IP associations.
- **Load Balancer Support**: Configure Application, Classic, or Network load balancers and optionally secure them with SSL/HTTPS certificates.
- **Environment Variables**: Dynamically maps environment properties (variables) to the application configuration.
- **Customizable Overrides**: Allows granular setting overrides for any Beanstalk option namespace/option.

## Usage

### Simple WebServer Environment

```hcl
module "elastic_beanstalk" {
  source = "./modules/elastic_beanstalk"

  name                = "my-web-app"
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Python 3.11"
  instance_type       = "t3.micro"

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

### Secured WebServer Environment inside VPC with SSL/HTTPS and Overrides

```hcl
module "elastic_beanstalk_advanced" {
  source = "./modules/elastic_beanstalk"

  name                = "my-advanced-app"
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Docker"
  instance_type       = "t3.medium"
  autoscale_min       = 2
  autoscale_max       = 5

  # VPC Configuration
  vpc_id                      = "vpc-0123456789abcdef0"
  subnets                     = ["subnet-abc12345", "subnet-def12345"]
  elb_subnets                 = ["subnet-pub12345", "subnet-pub67890"]
  elb_scheme                  = "public"
  associate_public_ip_address = false

  # HTTPS Configuration
  ssl_certificate_arn         = "arn:aws:acm:us-west-2:123456789012:certificate/abc-123-def-456"

  # Environment properties
  environment_properties = {
    DB_NAME = "appdb"
    APP_ENV = "production"
  }

  # Custom Setting Overrides
  setting_overrides = [
    {
      namespace = "aws:elasticbeanstalk:application"
      name      = "Application Healthcheck URL"
      value     = "/health"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Security Best Practice for Environment Properties
> [!IMPORTANT]
> To prevent leaking sensitive variables, do **not** hardcode credentials or keys in the `environment_properties` variable. Instead:
> 1. Store database credentials, API keys, and other secrets in **AWS Systems Manager (SSM) Parameter Store** or **AWS Secrets Manager**.
> 2. Grant the application instance profile role permissions to retrieve the secrets.
> 3. Read the secrets at runtime from the application layer.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Elastic Beanstalk Application and Environment. | `string` | n/a | yes |
| `tier` | The Elastic Beanstalk Environment tier. Valid values are `WebServer` or `Worker`. | `string` | `"WebServer"` | no |
| `solution_stack_name` | The name of the solution stack to use. Cannot be used with `platform_arn`. | `string` | `null` | no |
| `platform_arn` | The ARN of the platform version (solution stack) to use. Cannot be used with `solution_stack_name`. | `string` | `null` | no |
| `instance_type` | The EC2 instance type to use. | `string` | `"t3.micro"` | no |
| `autoscale_min` | The minimum number of instances in the Auto Scaling Group. | `number` | `1` | no |
| `autoscale_max` | The maximum number of instances in the Auto Scaling Group. | `number` | `2` | no |
| `loadbalancer_type` | The type of load balancer. Valid values: `classic`, `application`, `network`. | `string` | `"application"` | no |
| `vpc_id` | The ID of the VPC where resources should be deployed. | `string` | `null` | no |
| `subnets` | List of subnet IDs to deploy the EC2 instances. | `list(string)` | `[]` | no |
| `elb_subnets` | List of subnet IDs to deploy the Load Balancer (for custom VPCs). | `list(string)` | `[]` | no |
| `elb_scheme` | The scheme for the ELB. Valid values: `public`, `internal`. | `string` | `"public"` | no |
| `associate_public_ip_address` | Whether to associate public IP addresses with EC2 instances. | `bool` | `false` | no |
| `ssl_certificate_arn` | The ARN of the SSL certificate to attach to the load balancer for HTTPS. | `string` | `null` | no |
| `create_iam_resources` | Whether to create IAM roles and instance profiles for the environment. | `bool` | `true` | no |
| `instance_profile_name` | Existing IAM instance profile name. Required if `create_iam_resources` is `false`. | `string` | `null` | no |
| `service_role_arn` | Existing IAM service role ARN. Required if `create_iam_resources` is `false`. | `string` | `null` | no |
| `environment_properties` | A map of key-value pairs representing application environment variables. | `map(string)` | `{}` | no |
| `setting_overrides` | A list of configuration settings overrides. Each block requires namespace, name, value, and optionally resource. | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |
| `description` | A description of the Elastic Beanstalk environment. | `string` | `"Elastic Beanstalk Environment managed by Terraform"` | no |
| `application_description` | A description of the Elastic Beanstalk application. | `string` | `"Elastic Beanstalk Application managed by Terraform"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `app_name` | The name of the Elastic Beanstalk Application. |
| `app_arn` | The ARN of the Elastic Beanstalk Application. |
| `environment_id` | The ID of the Elastic Beanstalk Environment. |
| `environment_name` | The name of the Elastic Beanstalk Environment. |
| `environment_endpoint_url` | The URL to the Load Balancer for this Environment. |
| `environment_cname` | The fully qualified DNS name for this Environment. |
| `environment_tier` | The environment tier. |
| `ec2_role_name` | The name of the EC2 IAM Role created (or null if not created). |
| `ec2_role_arn` | The ARN of the EC2 IAM Role created (or null if not created). |
| `service_role_name` | The name of the Beanstalk Service IAM Role created (or null if not created). |
| `service_role_arn` | The ARN of the Beanstalk Service IAM Role created (or null if not created). |
| `instance_profile_name` | The name of the EC2 Instance Profile. |
