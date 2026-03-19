terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "us-west-2"
    bucket  = "my-app-development-us-my-app-111111111111"
    key     = "terraform.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "my-app-development-us-my-app-111111111111-lock"
  }
}
