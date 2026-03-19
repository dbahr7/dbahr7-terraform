terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "us-west-2"
    bucket  = "my-app-production-us-vpc-222222222222"
    key     = "terraform.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "my-app-production-us-vpc-222222222222-lock"
  }
}
