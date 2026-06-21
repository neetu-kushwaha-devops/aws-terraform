resource "aws_directory_service_directory" "this" {
  name       = var.name
  short_name = var.short_name
  password   = var.password
  type       = "MicrosoftAD"
  edition    = var.edition

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
