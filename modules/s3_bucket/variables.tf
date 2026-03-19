variable "bucket_name" {
  type        = string
  description = "name of the bucket"
}

variable "allowed_origins" {
  type        = string
  description = "Allows CORS domain for PUT and POST requests"
  default     = "*"
}

variable "versioning" {
  type        = string
  description = "Enabled or Disabled versioning"
  default     = "Enabled"
}

variable "lb_access_log_bucket" {
  type        = bool
  description = "Add policy to grant LBs to PUT access logs"
  default     = false
}

variable "additional_bucket_policies" {
  type        = string
  description = "Gets appended to the bucket policy"
  default     = ""
}

variable "eventbridge_notification" {
  type        = bool
  description = "Turn notifications on or off"
  default     = false
}
