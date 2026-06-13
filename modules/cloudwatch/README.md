# AWS CloudWatch Terraform Module

This module configures AWS CloudWatch resources, including customizable log groups, metric alarms with CPU/Memory/Billing thresholds, SNS topic integrations, and custom dashboards.

## Features

- **Customizable Log Group:** Automatically creates a CloudWatch Log Group with configurable log retention and KMS encryption.
- **Built-in Metric Alarms:**
  - **CPU Utilization Alarm:** Simple toggle to create CPU utilization alarms for EC2 or ECS workloads.
  - **Memory Utilization Alarm:** Simple toggle to monitor memory usage.
  - **Billing Alarm:** Monitor estimated charges and receive notifications when costs exceed your threshold.
- **SNS Integration:** Attach SNS topic ARNs to receive notifications for all alarm state transitions.
- **Custom Alarms:** Define any list of generic/custom alarms using standard metric parameters.
- **Custom Dashboards:** Deploy a CloudWatch dashboard with a default or fully custom layout.

## Usage

### Basic Example (Log Group and Default Dashboard)

```hcl
module "cloudwatch" {
  source = "./modules/cloudwatch"

  log_group_name              = "/aws/ecs/production-app"
  log_group_retention_in_days = 90
  
  create_dashboard            = true
  dashboard_name              = "production-system-metrics"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Advanced Example (With Alarms & SNS Integration)

```hcl
module "cloudwatch" {
  source = "./modules/cloudwatch"

  # Log Group Configuration
  log_group_name              = "/aws/application/prod"
  log_group_retention_in_days = 180

  # SNS Topic for Alarms
  sns_topic_arns              = ["arn:aws:sns:us-east-1:123456789012:ops-alerts-topic"]

  # CPU Alarm (EC2 Instance)
  cpu_alarm_enabled            = true
  cpu_alarm_threshold          = 85
  cpu_alarm_dimensions = {
    InstanceId = "i-08af7e923e421cdcf"
  }

  # Memory Alarm (ECS Service)
  memory_alarm_enabled         = true
  memory_alarm_threshold       = 80
  memory_alarm_namespace       = "AWS/ECS"
  memory_alarm_dimensions = {
    ClusterName = "production-ecs-cluster"
    ServiceName = "web-service"
  }

  # Billing Alarm
  billing_alarm_enabled        = true
  billing_alarm_threshold      = 250 # Alert if billing exceeds $250
  billing_alarm_currency       = "USD"

  # Custom Alarm (API Gateway 5XX Errors)
  custom_alarms = {
    api-5xx-errors = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "5XXError"
      namespace           = "AWS/ApiGateway"
      period              = 60
      statistic           = "Sum"
      threshold           = 5
      alarm_description   = "Triggered if API Gateway returns more than 5 5XX errors in a minute."
      dimensions = {
        ApiName = "production-api"
      }
    }
  }

  # Dashboard
  create_dashboard = true
  dashboard_name   = "production-performance-dashboard"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `create_log_group` | Whether to create a CloudWatch log group. | `bool` | `true` | no |
| `log_group_name` | The name of the log group. | `string` | `"/aws/application-logs"` | no |
| `log_group_retention_in_days` | The log retention in days. | `number` | `30` | no |
| `log_group_kms_key_id` | The ARN of the KMS Key to use when encrypting log data. | `string` | `null` | no |
| `sns_topic_arns` | SNS topic ARNs to trigger on alarm transitions. | `list(string)` | `[]` | no |
| `cpu_alarm_enabled` | Enable built-in CPU utilization alarm. | `bool` | `false` | no |
| `cpu_alarm_name` | Name of the CPU utilization alarm. | `string` | `null` | no |
| `cpu_alarm_threshold` | Threshold for CPU utilization (percentage). | `number` | `80` | no |
| `cpu_alarm_evaluation_periods` | Evaluation periods for CPU utilization. | `number` | `2` | no |
| `cpu_alarm_period` | Period (seconds) for CPU utilization. | `number` | `300` | no |
| `cpu_alarm_namespace` | Namespace for CPU utilization (e.g., AWS/EC2 or AWS/ECS). | `string` | `"AWS/EC2"` | no |
| `cpu_alarm_metric_name` | Metric name for CPU utilization. | `string` | `"CPUUtilization"` | no |
| `cpu_alarm_dimensions` | Dimensions for the CPU alarm. | `map(string)` | `{}` | no |
| `memory_alarm_enabled` | Enable built-in Memory utilization alarm. | `bool` | `false` | no |
| `memory_alarm_name` | Name of the Memory utilization alarm. | `string` | `null` | no |
| `memory_alarm_threshold` | Threshold for Memory utilization (percentage). | `number` | `80` | no |
| `memory_alarm_evaluation_periods` | Evaluation periods for Memory utilization. | `number` | `2` | no |
| `memory_alarm_period` | Period (seconds) for Memory utilization. | `number` | `300` | no |
| `memory_alarm_namespace` | Namespace for Memory utilization (e.g., AWS/ECS or CWAgent). | `string` | `"AWS/ECS"` | no |
| `memory_alarm_metric_name` | Metric name for Memory utilization. | `string` | `"MemoryUtilization"` | no |
| `memory_alarm_dimensions` | Dimensions for the Memory alarm. | `map(string)` | `{}` | no |
| `billing_alarm_enabled` | Enable built-in Billing/EstimatedCharges alarm. | `bool` | `false` | no |
| `billing_alarm_name` | Name of the Billing alarm. | `string` | `null` | no |
| `billing_alarm_threshold` | Threshold for Billing alarm (USD/currency). | `number` | `100` | no |
| `billing_alarm_currency` | Currency for the billing alarm. | `string` | `"USD"` | no |
| `billing_alarm_evaluation_periods` | Evaluation periods for Billing alarm. | `number` | `1` | no |
| `billing_alarm_period` | Period (seconds) for Billing alarm (should be at least 21600 seconds/6 hours). | `number` | `21600` | no |
| `custom_alarms` | A map of custom metric alarms to create. | `map(any)` | `{}` | no |
| `create_dashboard` | Whether to create a CloudWatch dashboard. | `bool` | `false` | no |
| `dashboard_name` | The name of the dashboard. | `string` | `null` | no |
| `dashboard_body` | The JSON body of the dashboard. If not provided, a default dashboard is generated. | `string` | `null` | no |
| `tags` | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `log_group_arn` | The ARN of the CloudWatch log group. |
| `log_group_name` | The name of the CloudWatch log group. |
| `cpu_alarm_arn` | The ARN of the CPU utilization alarm. |
| `memory_alarm_arn` | The ARN of the Memory utilization alarm. |
| `billing_alarm_arn` | The ARN of the Billing alarm. |
| `custom_alarm_arns` | A map of custom alarm names to their ARNs. |
| `dashboard_arn` | The ARN of the CloudWatch dashboard. |
