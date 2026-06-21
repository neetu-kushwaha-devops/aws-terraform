# AWS Service Catalog Terraform Module

This module manages an AWS Service Catalog Portfolio, creates and associates Service Catalog Products with provisioning artifacts, associates IAM Principals, and configures Launch Constraints.

## Features

- **Service Catalog Portfolio:** Creates a portfolio with customizable provider name, description, and tags.
- **Service Catalog Products:** Defines multiple products with provisioning artifacts (versions) backed by CloudFormation templates (via URL or template physical ID).
- **Product Associations:** Automatically associates created products with the portfolio, and allows associating additional pre-existing products.
- **Principal Associations:** Associates IAM users, groups, or roles with the portfolio to grant access.
- **Launch Constraints:** Applies launch role constraints to products (either internally created or external) so they provision resources using a specific IAM role.
- **Merged Tags:** Follows standard tagging patterns, automatically adding the `Name` tag merged with custom tags.

## Usage

### Complete Example (CloudFormation-Backed Products & Launch Constraints)

```hcl
module "service_catalog" {
  source = "./modules/service_catalog"

  name          = "enterprise-developer-portfolio"
  provider_name = "Cloud Platform Team"
  description   = "Standardized cloud resources for developer self-service provisioning."

  # Define products and their provisioning versions (artifacts)
  products = {
    s3_bucket = {
      name        = "secure-s3-bucket"
      owner       = "cloud-ops@example.com"
      description = "A standard secure S3 bucket with versioning and encryption."
      type        = "CLOUD_FORMATION_TEMPLATE"
      
      provisioning_artifacts = [
        {
          name         = "v1.0.0"
          description  = "Initial release with SSE-S3 encryption"
          template_url = "https://s3.amazonaws.com/my-cf-templates-bucket/s3-secure-v1.yaml"
        },
        {
          name         = "v1.1.0"
          description  = "Added option for KMS encryption"
          template_url = "https://s3.amazonaws.com/my-cf-templates-bucket/s3-secure-v2.yaml"
        }
      ]
      
      tags = {
        Category = "Storage"
      }
    },
    vpc_networks = {
      name        = "standard-vpc"
      owner       = "network-team@example.com"
      description = "3-tier VPC configuration conforming to security baseline."
      
      provisioning_artifacts = [
        {
          name                 = "v1.0.0"
          description          = "Base VPC setup"
          template_physical_id = "arn:aws:cloudformation:us-east-1:123456789012:stack/VpcTemplateStack/uuid"
        }
      ]
    }
  }

  # Associate IAM roles / users to allow access to launch products in this portfolio
  principal_arns = [
    "arn:aws:iam::123456789012:role/DeveloperAccessRole",
    "arn:aws:iam::123456789012:role/PlatformAdminRole"
  ]

  # Apply launch constraints using standard IAM roles for provisioning
  launch_constraints = {
    s3_launch = {
      product_key = "s3_bucket"
      role_arn    = "arn:aws:iam::123456789012:role/ServiceCatalogProvisioningRole"
      description = "Use dedicated role to provision S3 products."
    },
    vpc_launch = {
      product_key = "vpc_networks"
      role_arn    = "arn:aws:iam::123456789012:role/ServiceCatalogProvisioningRole"
    }
  }

  tags = {
    Environment = "production"
    Department  = "Platform-Engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the Service Catalog Portfolio. | `string` | n/a | yes |
| <a name="input_provider_name"></a> [provider\_name](#input\_provider\_name) | The provider name of the portfolio. | `string` | `"IT Team"` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the portfolio. | `string` | `"Service Catalog Portfolio"` | no |
| <a name="input_products"></a> [products](#input\_products) | A map of products to create and associate with the portfolio. The keys are logical identifiers. | <pre>map(object({<br>    name                 = string<br>    owner                = string<br>    description          = optional(string)<br>    distributor          = optional(string)<br>    support_email        = optional(string)<br>    support_description  = optional(string)<br>    support_url          = optional(string)<br>    type                 = optional(string, "CLOUD_FORMATION_TEMPLATE")<br>    provisioning_artifacts = list(object({<br>      name                        = string<br>      description                 = optional(string)<br>      template_url                = optional(string)<br>      template_physical_id        = optional(string)<br>      type                        = optional(string, "CLOUD_FORMATION_TEMPLATE")<br>      disable_template_validation = optional(bool, false)<br>    }))<br>    tags = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_additional_product_ids"></a> [additional\_product\_ids](#input\_additional\_product\_ids) | A list of existing Service Catalog Product IDs to associate with the portfolio. | `list(string)` | `[]` | no |
| <a name="input_principal_arns"></a> [principal\_arns](#input\_principal\_arns) | A list of IAM Principal ARNs to associate with the portfolio. | `list(string)` | `[]` | no |
| <a name="input_launch_constraints"></a> [launch\_constraints](#input\_launch\_constraints) | Map of launch constraints to apply. Keys can be the same keys as `products` map or external product IDs. | <pre>map(object({<br>    product_key = string<br>    role_arn    = string<br>    description = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_portfolio_id"></a> [portfolio\_id](#output\_portfolio\_id) | The ID of the Service Catalog Portfolio. |
| <a name="output_portfolio_arn"></a> [portfolio\_arn](#output\_portfolio\_arn) | The ARN of the Service Catalog Portfolio. |
| <a name="output_products_details"></a> [products\_details](#output\_products\_details) | A map of created products and their details (id, arn, name, type, owner, status, created_time). |
