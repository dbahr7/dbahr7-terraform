module "s3_bucket" {
  source          = "../../modules/s3_bucket"
  bucket_name     = "${local.application}-${local.environment}"
  allowed_origins = "https://*.${local.domain}"
}

module "valkey" {
  source = "../../modules/valkey"

  environment            = local.environment
  vpc_name               = "${local.application}-${local.environment}-main"
  parameter_store_prefix = local.parameter_store_prefix
  description            = "valkey for ${local.application}"
  replication_group_id   = "${local.application}-${local.environment}"
}

module "database" {
  source                 = "../../modules/rds"
  environment            = local.environment
  vpc_name               = "${local.application}-${local.environment}-main"
  parameter_store_prefix = local.parameter_store_prefix
  instance_name          = "${local.application}-${local.environment}"
  db_username            = replace(local.application, "-", "_")
  storage                = 100
  monitoring_interval    = 60
  bucket_name            = local.bucket_name
}

data "aws_acm_certificate" "cert" {
  domain   = local.domain
  statuses = ["ISSUED"]
}

module "my_app_ecs" {
  source                 = "../../modules/my_app_ecs"
  environment            = local.environment
  application            = local.application
  region                 = local.region
  parameter_store_prefix = local.parameter_store_prefix
  bucket_name            = local.bucket_name
  vpc_name               = "${local.application}-${local.environment}-main"
  domain                 = local.domain
  certificate_arn        = data.aws_acm_certificate.cert.arn

  valkey_sg_id = module.valkey.sg_id
  rds_sg_id    = module.database.sg_id

  web_count = 2

  site_name   = "EU App Platform"
  server_name = "EU.AppPlatform"

  dd_account_name              = local.dd_account_name
  datadog_log_forwarder_lambda = "datadog-forwarder-Forwarder-XXXXXXXXXXXX"
  database_monitoring_enabled  = true

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC00000000000000000000000000...00000000000000000000000000000000000000000000000000000 placeholder-key"
}

module "database_bridge" {
  source = "../../modules/database_bridge"

  environment            = local.environment
  application            = local.application
  region                 = local.region
  parameter_store_prefix = "${local.parameter_store_prefix}database_bridge/"
  vpc_name               = "${local.application}-${local.environment}-main"
  cluster_id             = module.my_app_ecs.cluster_id

  rds_sg_id     = module.database.sg_id
  database_host = module.database.host

  dd_account_name              = local.dd_account_name
  datadog_log_forwarder_lambda = "datadog-forwarder-Forwarder-XXXXXXXXXXXX"

  # This key pair may be shared across any other external services that need bridged access to the database
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC00000000000000000000000000000000000000000...00000000000000000000000000000000000000 placeholder-key"
}
