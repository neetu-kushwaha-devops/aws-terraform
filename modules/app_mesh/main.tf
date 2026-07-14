terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_appmesh_mesh" "this" {
  name = var.name

  spec {
    egress_filter {
      type = var.egress_filter_type
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_appmesh_virtual_node" "this" {
  for_each  = var.virtual_nodes
  name      = each.key
  mesh_name = aws_appmesh_mesh.this.name

  spec {
    dynamic "backend" {
      for_each = each.value.backends
      content {
        virtual_service {
          virtual_service_name = backend.value
        }
      }
    }

    dynamic "listener" {
      for_each = each.value.listeners
      content {
        port_mapping {
          port     = listener.value.port
          protocol = listener.value.protocol
        }
      }
    }

    dynamic "service_discovery" {
      for_each = each.value.service_discovery_dns_hostname != null ? [each.value.service_discovery_dns_hostname] : []
      content {
        dns {
          hostname = service_discovery.value
        }
      }
    }
  }

  tags = merge(
    {
      Name = "${var.name}-node-${each.key}"
    },
    var.tags
  )
}

resource "aws_appmesh_virtual_router" "this" {
  for_each  = var.virtual_routers
  name      = each.key
  mesh_name = aws_appmesh_mesh.this.name

  spec {
    dynamic "listener" {
      for_each = each.value.listeners
      content {
        port_mapping {
          port     = listener.value.port
          protocol = listener.value.protocol
        }
      }
    }
  }

  tags = merge(
    {
      Name = "${var.name}-router-${each.key}"
    },
    var.tags
  )
}

resource "aws_appmesh_route" "this" {
  for_each            = var.routes
  name                = each.key
  mesh_name           = aws_appmesh_mesh.this.name
  virtual_router_name = aws_appmesh_virtual_router.this[each.value.virtual_router_key].name

  spec {
    dynamic "http_route" {
      for_each = each.value.http_route != null ? [each.value.http_route] : []
      content {
        match {
          prefix = http_route.value.match_prefix
        }

        action {
          dynamic "weighted_target" {
            for_each = http_route.value.targets
            content {
              virtual_node = aws_appmesh_virtual_node.this[weighted_target.value.virtual_node_key].name
              weight       = weighted_target.value.weight
            }
          }
        }
      }
    }
  }

  tags = merge(
    {
      Name = "${var.name}-route-${each.key}"
    },
    var.tags
  )
}

resource "aws_appmesh_virtual_service" "this" {
  for_each  = var.virtual_services
  name      = each.key
  mesh_name = aws_appmesh_mesh.this.name

  spec {
    dynamic "provider" {
      for_each = each.value.provider_virtual_node_key != null ? [each.value.provider_virtual_node_key] : []
      content {
        virtual_node {
          virtual_node_name = aws_appmesh_virtual_node.this[provider.value].name
        }
      }
    }

    dynamic "provider" {
      for_each = each.value.provider_virtual_router_key != null ? [each.value.provider_virtual_router_key] : []
      content {
        virtual_router {
          virtual_router_name = aws_appmesh_virtual_router.this[provider.value].name
        }
      }
    }
  }

  tags = merge(
    {
      Name = "${var.name}-svc-${each.key}"
    },
    var.tags
  )
}
