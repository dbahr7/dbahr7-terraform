variable "application" {
  type        = string
  description = "eg. my-app, my-platform, etc"
}
variable "environment" {
  type        = string
  description = "eg. development, staging, production"
}

variable "region" {
  type        = string
  description = "AWS region. eg. us-west-1, eu-west-1"
}

variable "purpose" {
  type        = string
  default     = "main"
  description = "purpose of the VPC eg. main, scrubber, management"
}
