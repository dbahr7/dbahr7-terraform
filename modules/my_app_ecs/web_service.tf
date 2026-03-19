resource "aws_ecr_repository" "web" {
  name = "${var.application}-web"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_repository" "web" {
  name = aws_ecr_repository.web.name
}

locals {
  latest_web_tag     = coalesce(data.aws_ecr_repository.web.most_recent_image_tags[0], "latest")
  web_log_group_name = "/ecs/${var.application}/web"
}

resource "aws_cloudwatch_log_group" "web" {
  name              = local.web_log_group_name
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.application}-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.web_cpu
  memory                   = var.web_memory
  skip_destroy             = true
  execution_role_arn       = aws_iam_role.exec_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions = jsonencode([
    {
      name  = "web"
      image = "${aws_ecr_repository.web.repository_url}:${local.latest_web_tag}"
      portMappings = [{
        name          = "web-80-tcp"
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
        appProtocol   = "http"
      }]
      essential = true
      secrets   = local.secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.web_log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }, module.windows_datadog_container.container_definition
  ])

  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2022_CORE"
    cpu_architecture        = "X86_64"
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_lb_target_group" "web" {
  name                          = "${var.application}-web"
  target_type                   = "ip"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = data.aws_vpc.main.id
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 8
    path                = "/"
    port                = 80
    # figure out correct healthcheck endpoint and response later
    matcher = "200-399"
  }
}

resource "aws_ecs_service" "web" {
  name            = "${var.application}-web"
  cluster         = module.my_app_cluster.cluster_id
  task_definition = aws_ecs_task_definition.web.arn
  launch_type     = "FARGATE"
  propagate_tags  = "TASK_DEFINITION"

  desired_count                      = var.web_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web"
    container_port   = 80
  }

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # desired_count removed from ignore_changes to ensure Terraform enforces configured scaling
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_lambda_permission" "web_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = var.datadog_log_forwarder_lambda
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.web.arn
}

resource "aws_cloudwatch_log_subscription_filter" "web_datadog_log_subscription_filter" {
  name           = "datadog_log_subscription_filter"
  log_group_name = local.web_log_group_name
  # This function was created outside of TF
  destination_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.datadog_log_forwarder_lambda}"
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.web_lambda_permission]
}
