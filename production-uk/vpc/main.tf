module "vpc" {
  source      = "../../modules/vpc"
  application = local.application
  environment = local.environment
  region      = local.region
}
