data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "parameter_store_access" {
  name = "ecs-${var.application}-${var.environment}-parameter_store_access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
      }
    ]
  })
}

resource "aws_iam_policy" "create_log_group" {
  name = "ecs-${var.application}-${var.environment}-create_log_group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.application}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "task_policy" {
  name = "ecs-${var.application}-${var.environment}-task_policy"

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
        Sid = "ECSExecAccess"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Sid = "LoggStreamAccess"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.application}/*"]
      },
      {
        Sid      = "LogGroupAccess"
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role" "exec_role" {
  name               = "${var.application}-${var.environment}-exec_role"
  path               = "/ecs/${var.application}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachments_exclusive" "exec_role" {
  role_name = aws_iam_role.exec_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.parameter_store_access.arn,
    aws_iam_policy.create_log_group.arn
  ]
}

resource "aws_iam_role" "task_role" {
  name               = "${var.application}-${var.environment}-task_role"
  path               = "/ecs/${var.application}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachments_exclusive" "task_role" {
  role_name   = aws_iam_role.task_role.name
  policy_arns = [aws_iam_policy.task_policy.arn]
}
