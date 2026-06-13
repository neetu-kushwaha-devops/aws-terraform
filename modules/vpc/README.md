# Module: vpc

Skeleton Terraform module for creating an AWS VPC. Fill in resources and variables as needed.

Usage example:

module "vpc" {
  source = "../modules/vpc"
  name   = "example-vpc"
  cidr_block = "10.0.0.0/16"
  tags   = { Environment = "dev" }
}
