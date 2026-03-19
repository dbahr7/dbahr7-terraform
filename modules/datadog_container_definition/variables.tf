variable "environment" {
  type        = string
  description = "eg. development, staging, production"
}

variable "application" {
  type        = string
  description = "name of the application"
}

variable "dd_account_name" {
  type        = string
  description = "The 'account_name' to pass to DD_TAGS"
}

variable "working_directory" {
  type        = string
  default     = null
  description = "Working directory for the container. Must be set to C:\\ for windows containers"
}
