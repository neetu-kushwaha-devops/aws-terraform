# Module: internet_gateway

Skeleton Terraform module for creating an AWS Internet Gateway.

Usage example:

module "igw" {
  source = "../modules/internet_gateway"
  name   = "example-igw"
  vpc_id = module.vpc.vpc_id
}
