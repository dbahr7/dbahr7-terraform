data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

# This S3 backend must be bootstrapped according to the procedure in
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
module "terraform_state_backend" {
  source      = "cloudposse/tfstate-backend/aws"
  version     = "~> 1.5.0"
  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  attributes  = [data.aws_caller_identity.current.account_id]
  arn_format  = "arn:${data.aws_partition.current.partition}"

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = var.force_destroy
}
