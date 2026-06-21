# AWS WorkSpaces Terraform Module - outputs.tf
# Output definitions for the WorkSpaces module.

output "workspaces_details" {
  description = "A map of created WorkSpaces with their details"
  value = {
    for k, v in aws_workspaces_workspace.this : k => {
      id            = v.id
      ip_address    = v.ip_address
      state         = v.state
      computer_name = v.computer_name
      user_name     = v.user_name
    }
  }
}

output "directory_id" {
  description = "The ID of the registered WorkSpaces directory"
  value       = var.register_directory ? aws_workspaces_directory.this[0].id : var.directory_id
}

output "ip_group_id" {
  description = "The ID of the IP access control group, if created"
  value       = length(var.ip_rules) > 0 ? aws_workspaces_ip_group.this[0].id : null
}
