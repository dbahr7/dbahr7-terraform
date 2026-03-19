variable "environment" {
  type        = string
  description = "eg. development, staging, production"
}

variable "purpose" {
  type        = string
  default     = "main"
  description = "purpose of the RDS instance eg. main, scrubber, management"
}

variable "parameter_store_prefix" {
  type        = string
  description = "the prefix for parameters that the intended service can access"
}

variable "vpc_name" {
  type        = string
  description = "name of the VPC to place the DB in"
}

variable "engine" {
  type        = string
  default     = "sqlserver-se"
  description = "Database engine"
}

variable "engine_version" {
  type        = string
  default     = "16.00.4185.3.v1"
  description = "Database version"
}

variable "instance_class" {
  type    = string
  default = "db.t3.xlarge"
}

variable "instance_name" {
  type        = string
  description = "name of RDS instance"
}

variable "db_username" {
  type        = string
  description = "master username"
}

variable "ca_cert_identifier" {
  type    = string
  default = "rds-ca-xxxxxx-g1"
}
variable "storage" {
  type        = number
  default     = 50
  description = "DB storage size in GB"
  validation {
    condition     = var.storage >= 20
    error_message = "storage must be ≥ 20 GB."
  }
}

variable "monitoring_interval" {
  type        = number
  default     = 0
  description = "Set to 0 to disable. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of 0/1/5/10/15/30/60."
  }
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Safeguard against accidental modifications."
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket where native MS SQL backups are stored"
}
