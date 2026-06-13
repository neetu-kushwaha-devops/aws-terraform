resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = length(var.availability_zones) > 0 ? element(var.availability_zones, count.index) : null
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = length(var.availability_zones) > 0 ? "${var.name}-public-${element(var.availability_zones, count.index)}" : "${var.name}-public-${count.index}"
      Type = "Public"
    },
    var.tags,
    var.public_subnet_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                  = var.vpc_id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = length(var.availability_zones) > 0 ? element(var.availability_zones, count.index) : null
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = length(var.availability_zones) > 0 ? "${var.name}-private-${element(var.availability_zones, count.index)}" : "${var.name}-private-${count.index}"
      Type = "Private"
    },
    var.tags,
    var.private_subnet_tags
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id                  = var.vpc_id
  cidr_block              = var.database_subnets[count.index]
  availability_zone       = length(var.availability_zones) > 0 ? element(var.availability_zones, count.index) : null
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = length(var.availability_zones) > 0 ? "${var.name}-database-${element(var.availability_zones, count.index)}" : "${var.name}-database-${count.index}"
      Type = "Database"
    },
    var.tags,
    var.database_subnet_tags
  )
}

resource "aws_db_subnet_group" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  name        = "${var.name}-database"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(
    {
      Name = "${var.name}-database-subnet-group"
    },
    var.tags
  )
}
