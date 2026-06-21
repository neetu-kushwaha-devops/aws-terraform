variable "name" {
  description = "The name of the placement group"
  type        = string
}

variable "strategy" {
  description = "The placement strategy. Can be cluster, partition, or spread."
  type        = string
  default     = "partition"
  validation {
    condition     = contains(["cluster", "partition", "spread"], var.strategy)
    error_message = "Strategy must be one of: cluster, partition, or spread."
  }
}

variable "partition_count" {
  description = "The number of partitions to create. Only valid when strategy is partition."
  type        = number
  default     = 3
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
