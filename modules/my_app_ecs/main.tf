module "my_app_cluster" {
  source = "../ecs_cluster"

  environment = var.environment
  application = var.application
}

module "datadog_dbm" {
  count  = var.database_monitoring_enabled ? 1 : 0
  source = "../mssql_datadog"

  environment            = var.environment
  application            = var.application
  vpc_name               = var.vpc_name
  parameter_store_prefix = var.parameter_store_prefix
  dd_account_name        = var.dd_account_name
  ecs_cluster_arn        = module.my_app_cluster.cluster_id
}

module "microservices_ec2" {
  count  = var.microservices_ec2_enabled ? 1 : 0
  source = "../microservices_ec2"

  environment                  = var.environment
  application                  = var.application
  region                       = var.region
  vpc_name                     = var.vpc_name
  parameter_store_prefix       = var.parameter_store_prefix
  dd_account_name              = var.dd_account_name
  bucket_name                  = var.bucket_name
  datadog_log_forwarder_lambda = var.datadog_log_forwarder_lambda
  public_key                   = var.public_key
  ami                          = var.ami
}
