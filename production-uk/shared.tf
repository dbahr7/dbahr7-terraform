locals {
  region                 = "eu-west-1"
  environment            = "production-uk"
  application            = "my-app"
  parameter_store_prefix = "/${local.environment}/${local.application}/"
  bucket_name            = "${local.application}-${local.environment}"
  domain                 = "example.eu"
  dd_account_name        = "my_company_production"
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      environment = local.environment
      application = local.application
      namespace   = local.application
      managed-by  = "Terraform"
      Department  = "Digital Platforms"
    }
  }
}
