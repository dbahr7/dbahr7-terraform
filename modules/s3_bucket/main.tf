data "aws_region" "current" {}


locals {
  region_account_id_mapping = {
    us-west-2 = XXXXXXXXXXXX
    eu-west-1 = XXXXXXXXXXXX
  }

  # see https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  # for a list of elb-account-ids
  lb_access_log_statement = <<STATEMENT
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::${local.region_account_id_mapping[data.aws_region.current.name]}:root"
  },
  "Action": "s3:PutObject",
  "Resource": "${aws_s3_bucket.bucket.arn}/*"
}
STATEMENT
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "control" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceTlsRequestsOnly",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*",
        "${aws_s3_bucket.bucket.arn}"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
    ${var.lb_access_log_bucket ? join("\n", [",", local.lb_access_log_statement]) : ""}
    ${var.additional_bucket_policies != "" ? join("\n", [",", var.additional_bucket_policies]) : ""}
  ]
}
POLICY
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = [var.allowed_origins]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_notification" "eventbridge_notification" {
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = var.eventbridge_notification
}
