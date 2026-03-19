variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable"
  default     = false
}

variable "namespace" {
  type        = string
  description = "namespace to pass to the terraform_state_backend module"
  default     = "my-app"
}

variable "environment" {
  type        = string
  description = "environment to pass to the terraform_state_backend module, eg. development, staging, production"
}

variable "name" {
  type        = string
  description = "name to pass to the terraform_state_backend module, eg. rds, iam, ecs_cluster"
}
