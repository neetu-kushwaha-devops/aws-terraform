terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  # Leaving ingress and egress empty removes all default rules to secure the VPC
  ingress = []
  egress  = []

  tags = merge(
    {
      Name = "${var.name}-default-sg"
    },
    var.tags
  )
}
