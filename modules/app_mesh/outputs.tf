output "mesh_id" {
  description = "The ID of the service mesh"
  value       = aws_appmesh_mesh.this.id
}

output "mesh_arn" {
  description = "The ARN of the service mesh"
  value       = aws_appmesh_mesh.this.arn
}

output "virtual_node_ids" {
  description = "Map of virtual node IDs created"
  value       = { for k, v in aws_appmesh_virtual_node.this : k => v.id }
}

output "virtual_router_ids" {
  description = "Map of virtual router IDs created"
  value       = { for k, v in aws_appmesh_virtual_router.this : k => v.id }
}

output "virtual_service_ids" {
  description = "Map of virtual service IDs created"
  value       = { for k, v in aws_appmesh_virtual_service.this : k => v.id }
}
