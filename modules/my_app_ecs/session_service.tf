# Consider extact service and ecr logic into module when we have more than 2 services.
resource "aws_ecr_repository" "session" {
  name = "${var.application}-session"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_repository" "session" {
  name = aws_ecr_repository.session.name
}

data "aws_ssm_parameters_by_path" "env_vars" {
  path = var.parameter_store_prefix
}

locals {
  secrets = [for n in data.aws_ssm_parameters_by_path.env_vars.names :
    {
      name      = trimprefix(n, var.parameter_store_prefix)
      valueFrom = n
    }
  ]
  latest_session_tag     = coalesce(data.aws_ecr_repository.session.most_recent_image_tags[0], "latest")
  session_log_group_name = "/ecs/${var.application}/session"
}

resource "aws_cloudwatch_log_group" "session" {
  name              = local.session_log_group_name
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "session" {
  family                   = "${var.application}-session"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.session_cpu
  memory                   = var.session_memory
  skip_destroy             = true
  execution_role_arn       = aws_iam_role.exec_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions = jsonencode([
    {
      name  = "session"
      image = "${aws_ecr_repository.session.repository_url}:${local.latest_session_tag}"
      portMappings = [{
        name          = "session-3000-tcp"
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
        appProtocol   = "http"
      }]
      essential = true
      command   = ["/bin/sh", "-c", "forever", "-l", "console.log", "-e", "-a", "-c", "node", "app.js"]
      secrets   = local.secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.session_log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }, module.linux_datadog_container.container_definition
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_lb_target_group" "session" {
  name                          = "${var.application}-session"
  target_type                   = "ip"
  port                          = 3000
  protocol                      = "HTTP"
  vpc_id                        = data.aws_vpc.main.id
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 8
    path                = "/"
    port                = 3000
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "session" {
  listener_arn = aws_lb_listener.web_443.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.session.arn
  }

  condition {
    host_header {
      values = ["session.${var.domain}"]
    }
  }

  tags = {
    Name = "session"
  }
}

resource "aws_ecs_service" "session" {
  name            = "${var.application}-session"
  cluster         = module.my_app_cluster.cluster_id
  task_definition = aws_ecs_task_definition.session.arn
  launch_type     = "FARGATE"
  propagate_tags  = "TASK_DEFINITION"

  desired_count                      = var.session_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.session.arn
    container_name   = "session"
    container_port   = 3000
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

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_lambda_permission" "session_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = var.datadog_log_forwarder_lambda
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.session.arn
}

resource "aws_cloudwatch_log_subscription_filter" "session_datadog_log_subscription_filter" {
  name           = "datadog_log_subscription_filter"
  log_group_name = local.session_log_group_name
  # This function was created outside of TF
  destination_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.datadog_log_forwarder_lambda}"
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.session_lambda_permission]
}
