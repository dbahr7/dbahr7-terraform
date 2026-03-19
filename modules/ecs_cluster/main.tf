resource "aws_ecs_cluster" "cluster" {
  name = "${var.application}-${var.environment}"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

resource "aws_cloudwatch_event_rule" "stopped_tasks" {
  name_prefix = "${aws_ecs_cluster.cluster.name}-stopped-tasks"
  event_pattern = jsonencode({
    "detail-type" : [
      "ECS Task State Change",
    ],
    "source" : [
      "aws.ecs",
    ],
    "detail" : {
      "clusterArn" : [aws_ecs_cluster.cluster.arn],
      "desiredStatus" : [
        "STOPPED",
      ],
      "lastStatus" : [
        "STOPPED",
      ],
    }
  })
}

resource "aws_cloudwatch_event_target" "stopped_tasks" {
  rule = aws_cloudwatch_event_rule.stopped_tasks.name
  arn  = aws_cloudwatch_log_group.stopped_tasks.arn
}

resource "aws_cloudwatch_log_group" "stopped_tasks" {
  name              = "/aws/events/${aws_ecs_cluster.cluster.name}/stopped-tasks"
  retention_in_days = 14
}

data "aws_iam_policy_document" "stopped_tasks_log" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.stopped_tasks.arn}:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.stopped_tasks.arn}:*:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.stopped_tasks.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "stopped_tasks" {
  policy_document = data.aws_iam_policy_document.stopped_tasks_log.json
  policy_name     = "${aws_ecs_cluster.cluster.name}-stopped-tasks-log"
}
