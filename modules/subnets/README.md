# Module: subnets

Skeleton Terraform module for creating AWS Subnets.

Usage example:

module "subnets" {
  source = "../modules/subnets"
  name   = "example-subnet"
  vpc_id = module.vpc.vpc_id
  cidr_block = "10.0.1.0/24"
  tags   = { Environment = "dev" }
}
