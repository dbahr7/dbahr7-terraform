# delete this file when App switches away from iam user access keys https://your-project-management-tool.example.com/task/XXXX

resource "aws_iam_user" "temp" {
  name = local.application
}

resource "aws_iam_access_key" "temp" {
  user = aws_iam_user.temp.name
}

data "aws_iam_policy_document" "temp" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
      "arn:aws:s3:::${local.bucket_name}"
    ]
  }
}

resource "aws_iam_user_policy" "temp" {
  name   = "s3-access"
  user   = aws_iam_user.temp.name
  policy = data.aws_iam_policy_document.temp.json
}

resource "aws_ssm_parameter" "temp_access_key_id" {
  name  = "${local.parameter_store_prefix}ACCESS_KEY_ID"
  type  = "String"
  value = aws_iam_access_key.temp.id
}

resource "aws_ssm_parameter" "temp_access_key_secret" {
  name  = "${local.parameter_store_prefix}ACCESS_KEY_SECRET"
  type  = "SecureString"
  value = aws_iam_access_key.temp.secret
}
