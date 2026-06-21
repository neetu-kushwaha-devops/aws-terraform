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
