variable "parameter_store_prefix" {
  type        = string
  description = "the prefix for parameters that the application can access"
}

variable "environment" {
  type        = string
  description = "eg. development, staging, production"
}

variable "application" {
  type        = string
  description = "name of the application"
}

variable "vpc_name" {
  type        = string
  description = "name of the VPC to place the ECS cluster in"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster to run the task in"
}

variable "dd_account_name" {
  type        = string
  description = "The 'account_name' to pass to DD_TAGS"
}
