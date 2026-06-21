resource "aws_resourcegroups_group" "this" {
  name        = var.name
  description = var.description

  dynamic "resource_query" {
    for_each = length(var.configuration) == 0 ? [1] : []
    content {
      type = var.query_type
      query = var.query_type == "TAG_FILTERS_1_0" ? jsonencode({
        ResourceTypeFilters = var.resource_type_filters
        TagFilters = [
          for k, v in var.query_tags : {
            Key    = k
            Values = v
          }
        ]
        }) : jsonencode({
        ResourceTypeFilters = var.resource_type_filters
        StackIdentifier     = var.query_stack_identifier
      })
    }
  }

  dynamic "configuration" {
    for_each = var.configuration
    content {
      type = configuration.value.type

      dynamic "parameters" {
        for_each = configuration.value.parameters
        content {
          name   = parameters.value.name
          values = parameters.value.values
        }
      }
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
