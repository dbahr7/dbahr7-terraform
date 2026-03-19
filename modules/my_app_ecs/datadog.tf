module "linux_datadog_container" {
  source = "../datadog_container_definition"

  application     = var.application
  environment     = var.environment
  dd_account_name = var.dd_account_name
}

module "windows_datadog_container" {
  source = "../datadog_container_definition"

  application       = var.application
  environment       = var.environment
  dd_account_name   = var.dd_account_name
  working_directory = "C:\\"
}
