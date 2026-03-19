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

variable "dd_account_name" {
  type        = string
  description = "The 'account_name' to pass to DD_TAGS"
}

variable "bucket_name" {
  type        = string
  description = "name the of the bucket the application uses"
}

variable "parameter_store_prefix" {
  type        = string
  description = "the prefix for parameters that the application can access"
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

variable "ami" {
  type        = string
  description = "Manually look up the correct AMI to use and pass it into this module. Work on replacing the EC2 instance has already started so this module shouldn't live long enough to add logic for dynamic lookup"
  default     = "ami-0440a5f5e96917e8f"
}
