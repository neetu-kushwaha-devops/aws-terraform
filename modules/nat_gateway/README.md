# Module: nat_gateway

Skeleton Terraform module for creating an AWS NAT Gateway.

Usage example:

module "nat" {
  source = "../modules/nat_gateway"
  name   = "example-nat"
  subnet_id = module.subnets.subnet_id
}
