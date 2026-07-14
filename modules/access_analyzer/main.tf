terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = var.name
  type          = var.type

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
