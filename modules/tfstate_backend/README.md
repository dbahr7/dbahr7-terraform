# tfstate_backend module

Terraform module to provision an S3 bucket to store `terraform.tfstate` file and a DynamoDB table to lock the state file to prevent concurrent modifications and state corruption.

This is a thin wrapper around ["cloudposse/tfstate-backend/aws"](https://github.com/cloudposse/terraform-aws-tfstate-backend) that adds extra bits of useful defaults and security:

- S3 buckets and DynamoDB tables created by this module will have "tfstate-${aws_account_id}"
  in their names.

## Usage

Initializing and destroying root modules that use this module require a few extra steps.
See the README of the upstream module for details:

- [How to initialize](https://github.com/cloudposse/terraform-aws-tfstate-backend#create)
- [How to destroy](https://github.com/cloudposse/terraform-aws-tfstate-backend#destroy)
