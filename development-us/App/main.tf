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

  web_count = 1

  dd_account_name              = local.dd_account_name
  datadog_log_forwarder_lambda = "datadog-forwarder-Forwarder-XXXXXXXXXXXX"
  database_monitoring_enabled  = true

  site_name   = "DEV App Platform"
  server_name = "DEV.AppPlatform"

  microservices_ec2_enabled = true

  ami = "ami-01cc7b75f51e45f7e" # Windows Server 2022 for us-west-2

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC00000000000000000000000000000000000...00000000000000000000000 placeholder-key" # UPDATE: Replace with your public key
}




