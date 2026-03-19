locals {
  region                 = "us-west-2"
  environment            = "production-us"
  application            = "my-app"
  parameter_store_prefix = "/${local.environment}/${local.application}/"
  bucket_name            = "${local.application}-${local.environment}"
  domain                 = "example.com"
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
