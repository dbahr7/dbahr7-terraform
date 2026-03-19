variable "environment" {
  type        = string
  description = "eg. development, staging, production"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "purpose" {
  type        = string
  default     = "main"
  description = "purpose of the app eg. main, scrubber, management"
}

variable "vpc_name" {
  type        = string
  description = "name of the VPC to place the ECS cluster in"
}

variable "application" {
  type        = string
  description = "name of the application"
}

variable "bucket_name" {
  type        = string
  description = "name the of the bucket the application uses"
}

variable "domain" {
  type        = string
  description = "The domain of the application eg. example.eu"
}

# Will apply without errors if referencing non-existent tag bug task will not start up
variable "image_tag" {
  type        = string
  description = "Tag of an uploaded image"
  default     = "initial-tag"
}

variable "parameter_store_prefix" {
  type        = string
  description = "the prefix for parameters that the application can access"
}

# See valid values for CPU and memory:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
variable "web_cpu" {
  type        = string
  description = "cpu used by the task"
  default     = "2048"
}

variable "web_memory" {
  type        = string
  description = "memory used by the task"
  default     = "4096"
}

variable "session_cpu" {
  type        = string
  description = "cpu used by the task"
  default     = "2048"
}

variable "session_memory" {
  type        = string
  description = "memory used by the task"
  default     = "4096"
}

variable "web_count" {
  type        = number
  description = "default number of web tasks during business hours"
  default     = 1
}

variable "session_count" {
  type        = number
  description = "default number of session tasks during business hours"
  default     = 1
}

variable "certificate_arn" {
  type        = string
  description = "the cert ARN"
}

variable "dd_account_name" {
  type        = string
  description = "The 'account_name' to pass to DD_TAGS"
}

variable "database_monitoring_enabled" {
  type        = bool
  description = "Turn on of off Datadog SQL level monitoring"
  default     = false
}

variable "valkey_sg_id" {
  type        = string
  description = "Valkey SG to allow access to and from"
}

variable "rds_sg_id" {
  type        = string
  description = "RDS SG to allow access to and from"
}

variable "datadog_log_forwarder_lambda" {
  type        = string
  description = "Name of the lambda function that forwards logs from cloudwatch to Datadog"
}

variable "microservices_ec2_enabled" {
  type        = bool
  description = "Enable or disable microservices EC2 instance"
  default     = true
}

variable "public_key" {
  type        = string
  description = "Public RSA key. Generate it locally on your own machine and save the private key in 1password"
}

variable "site_name" {
  type        = string
  description = "Site display name"
}

variable "server_name" {
  type        = string
  description = "Server identifier name"
}

variable "ami" {
  type        = string
  description = "AMI ID for microservices EC2 instance"
  default     = "ami-0440a5f5e96917e8f"
}
