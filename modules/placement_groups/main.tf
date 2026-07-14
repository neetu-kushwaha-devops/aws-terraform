terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_placement_group" "this" {
  name            = var.name
  strategy        = var.strategy
  partition_count = var.strategy == "partition" ? var.partition_count : null

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
