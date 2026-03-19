data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = "private-compute"
  }
}

resource "aws_ecr_repository" "datadog_dbm" {
  name = "${var.application}-datadog-dbm"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "datadog_dbm" {
  name = "${var.application}-${var.environment}-datadog-agent-dbm-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachments_exclusive" "datadog_dbm" {
  role_name   = aws_iam_role.datadog_dbm.name
  policy_arns = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role_policy" "datadog_dbm" {
  name = "read-ssm"
  role = aws_iam_role.datadog_dbm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Effect = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/COMMON/*",
          "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.parameter_store_prefix}MSSQL_HOST",
          "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.parameter_store_prefix}DD_DATABASE_PASSWORD"
        ]
      },
    ]
  })
}

resource "aws_ecs_task_definition" "datadog_dbm" {
  family                   = "${var.application}-datadog-agent-dbm"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.datadog_dbm.arn

  container_definitions = jsonencode([
    {
      name  = "datadog-agent-dbm"
      image = "${aws_ecr_repository.datadog_dbm.repository_url}:latest"
      portMappings = [
      ]
      essential = true
      environment = [
        {
          name  = "DD_SITE"
          value = "datadoghq.com"
        },
        {
          name  = "DD_PROCESS_AGENT_ENABLED"
          value = "false"
        },
        {
          name  = "DD_APM_ENABLED"
          value = "false"
        },
        {
          name  = "DD_LOGS_ENABLED"
          value = "false"
        },
        {
          name  = "DD_TAGS"
          value = "account_name:${var.dd_account_name}"
        },
        {
          name  = "DD_ENV"
          value = "${var.environment}"
        }
      ]
      secrets = [
        {
          name      = "DD_API_KEY"
          valueFrom = "/COMMON/DD_API_KEY"
        },
        {
          name      = "DATABASE_HOST"
          valueFrom = "${var.parameter_store_prefix}MSSQL_HOST"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "${var.parameter_store_prefix}DD_DATABASE_PASSWORD"
        }
      ]
      healthCheck = {
        retries     = 3
        command     = ["CMD-SHELL", "agent health"]
        timeout     = 5
        interval    = 30
        startPeriod = 15
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_security_group" "datadog_dbm" {
  name        = "${var.application}-datadog-dbm"
  description = "Allow egress"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "datadog_dbm" {
  name            = "${var.application}-datadog-dbm"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.datadog_dbm.arn
  launch_type     = "FARGATE"
  propagate_tags  = "TASK_DEFINITION"

  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.datadog_dbm.id]
    assign_public_ip = false
  }
}
