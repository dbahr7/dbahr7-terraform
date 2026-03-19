
data "aws_iam_policy_document" "backup_restore" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "backup_restore" {
  name = "${var.instance_name}-sql-server-backup-restore"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "BucketAccess"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "backup_restore" {
  name               = "${var.instance_name}-backup-restore"
  path               = "/rds/${var.instance_name}-backup-restore/"
  assume_role_policy = data.aws_iam_policy_document.backup_restore.json
}

resource "aws_iam_role_policy_attachments_exclusive" "backup_restore" {
  role_name   = aws_iam_role.backup_restore.name
  policy_arns = [aws_iam_policy.backup_restore.arn]
}

resource "aws_db_option_group" "mssql" {
  name                     = "${var.instance_name}-option-group"
  option_group_description = "${var.instance_name} option group"
  engine_name              = var.engine
  major_engine_version     = substr(var.engine_version, 0, 5)

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.backup_restore.arn
    }
  }
}
