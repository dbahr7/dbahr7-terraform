data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "microservices_ec2" {
  name = "${var.application}-${var.environment}-microservices_ec2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "BucketAccess"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAttributes",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
      },
      {
        Sid = "LoggStreamAccess"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ec2/${var.application}/*"]
      },
      {
        Sid = "DescribeEC2Tags"
        Action = [
          "ec2:DescribeTags",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/COMMON/*",
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.parameter_store_prefix}*"
        ]
      },
      {
        Sid = "StoreCloudWatchConfig"
        Action = [
          "ssm:PutParameter",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.parameter_store_prefix}AmazonCloudWatch-windows"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "microservices_ec2_role" {
  name               = "${var.application}-${var.environment}-microservices_ec2_role"
  path               = "/ec2/${var.application}/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "microservices_ec2_profile" {
  name = "${var.application}-${var.environment}-microservices_ec2_profile"
  role = aws_iam_role.microservices_ec2_role.name
}

resource "aws_iam_role_policy_attachments_exclusive" "microservices_ec2_role" {
  role_name = aws_iam_role.microservices_ec2_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.microservices_ec2.arn
  ]
}
