resource "aws_ecr_repository" "my_app_ssh_proxy" {
  name = "my-app-ssh-proxy"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_repository" "my_app_ssh_proxy" {
  name = aws_ecr_repository.my_app_ssh_proxy.name
}

locals {
  latest_tag       = coalesce(data.aws_ecr_repository.my_app_ssh_proxy.most_recent_image_tags[0], "latest")
  chamber_services = trim(var.parameter_store_prefix, "/")
  log_group_name   = "/ecs/${var.application}/database-bridge"
}

resource "aws_cloudwatch_log_group" "database_bridge" {
  name              = local.log_group_name
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "database_bridge" {
  family                   = "${var.application}-database-bridge"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  skip_destroy             = true
  execution_role_arn       = aws_iam_role.exec_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions = jsonencode([
    {
      name  = "main"
      image = "${aws_ecr_repository.my_app_ssh_proxy.repository_url}:${local.latest_tag}"
      portMappings = [{
        name          = "ssh"
        containerPort = 2222
        hostPort      = 2222
        protocol      = "tcp"
        appProtocol   = "http"
      }]
      essential = true
      environment = [
        {
          name  = "CHAMBER_SERVICES"
          value = local.chamber_services
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }, module.datadog_container.container_definition
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "database_bridge" {
  name            = "${var.application}-database-bridge"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.database_bridge.arn
  launch_type     = "FARGATE"
  propagate_tags  = "TASK_DEFINITION"

  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.database_bridge.arn
    container_name   = "main"
    container_port   = 2222
  }

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.database_bridge_ecs_task.id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

resource "aws_lambda_permission" "database_bridge_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = var.datadog_log_forwarder_lambda
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.database_bridge.arn
}

resource "aws_cloudwatch_log_subscription_filter" "database_bridge_datadog_log_subscription_filter" {
  name           = "datadog_log_subscription_filter"
  log_group_name = local.log_group_name
  # This function was created outside of TF
  destination_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.datadog_log_forwarder_lambda}"
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.database_bridge_lambda_permission]
}
