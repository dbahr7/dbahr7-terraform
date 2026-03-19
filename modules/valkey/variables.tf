variable "environment" {
  type        = string
  description = "eg. development-us, staging-us, production-uk, etc"
}

variable "purpose" {
  type        = string
  default     = "main"
  description = "purpose of the Valkey Cluster eg. main, scrubber, management"
}

variable "parameter_store_prefix" {
  type        = string
  description = "the prefix for parameters that the intended service can access"
}

variable "vpc_name" {
  type        = string
  description = "name of the VPC to place the DB in"
}

variable "description" {
  type        = string
  description = "description of the redis cluster"
}

variable "replication_group_id" {
  type        = string
  description = "Replication group identifier aka name of cluster. Must be lowercase"
}

variable "engine_version" {
  type        = string
  description = "version of valkey"
  default     = "8.0"
}

variable "node_type" {
  type        = string
  description = "instance type of the cluster"
  default     = "cache.t4g.micro"
}
