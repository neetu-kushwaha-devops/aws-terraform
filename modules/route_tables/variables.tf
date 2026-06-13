variable "name" {
  description = "Name prefix for the route table resources"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the route tables should be created"
  type        = string
}

variable "route_tables" {
  description = <<EOF
Map of route tables to create. Keys are logical IDs (e.g. public, private).
Each route table can have:
- name: (Required) Name tag of the route table
- routes: (Optional) List of route configurations:
  - cidr_block: (Optional) Destination CIDR block
  - ipv6_cidr_block: (Optional) Destination IPv6 CIDR block
  - destination_prefix_list_id: (Optional) Destination Prefix List ID
  - gateway_id: (Optional) Internet gateway or Virtual private gateway ID
  - nat_gateway_id: (Optional) NAT gateway ID
  - transit_gateway_id: (Optional) Transit gateway ID
  - vpc_peering_connection_id: (Optional) VPC Peering connection ID
  - egress_only_gateway_id: (Optional) Egress Only Internet gateway ID
  - network_interface_id: (Optional) Network interface ID
  - vpc_endpoint_id: (Optional) VPC Endpoint ID
- subnets: (Optional) List of subnet IDs to associate with this route table
- tags: (Optional) Map of tags specific to this route table
EOF
  type        = any
  default     = {}
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
