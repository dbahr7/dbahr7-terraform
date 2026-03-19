module "datadog_container" {
  source = "../datadog_container_definition"

  application     = var.application
  environment     = var.environment
  dd_account_name = var.dd_account_name
}
