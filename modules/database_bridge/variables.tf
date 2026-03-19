variable "environment" {
  type        = string
  description = "eg. development, staging, production"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "application" {
  type        = string
  description = "name of the application"
}

variable "vpc_name" {
  type        = string
  description = "name of the VPC to place the ECS cluster in"
}

variable "cluster_id" {
  type        = string
  description = "Cluster ID to place the database bridge in"
}

variable "parameter_store_prefix" {
  type        = string
  description = "the prefix for parameters that the application can access"
}

variable "cpu" {
  type        = string
  description = "cpu used by the task"
  default     = "256"
}

variable "memory" {
  type        = string
  description = "memory used by the task"
  default     = "512"
}

variable "rds_sg_id" {
  type        = string
  description = "RDS SG to allow access to and from"
}

variable "dd_account_name" {
  type        = string
  description = "The 'account_name' to pass to DD_TAGS"
}

variable "datadog_log_forwarder_lambda" {
  type        = string
  description = "Name of the lambda function that forwards logs from cloudwatch to Datadog"
}

variable "public_key" {
  type        = string
  description = "public openssh key"
}

variable "database_host" {
  type        = string
  description = "host of the DB to bridge to"
}

variable "database_port" {
  type        = string
  description = "port that the DB will be listening on"
  default     = "1433"
}
