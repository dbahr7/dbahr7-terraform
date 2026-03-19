terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "eu-west-1"
    bucket  = "my-app-production-uk-my-app-222222222222"
    key     = "terraform.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "my-app-production-uk-my-app-222222222222-lock"
  }
}
