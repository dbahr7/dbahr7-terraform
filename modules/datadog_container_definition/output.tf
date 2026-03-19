output "container_definition" {
  value = {
    name      = "datadog-agent"
    image     = "public.ecr.aws/datadog/agent:latest"
    essential = true
    secrets = [
      {
        name      = "DD_API_KEY"
        valueFrom = "/COMMON/DD_API_KEY"
      }
    ],
    environment = [
      {
        name  = "ECS_FARGATE"
        value = "true"
      },
      {
        name  = "DD_APM_ENABLED"
        value = "true"
      },
      {
        name  = "DD_PROFILING_ENABLED"
        value = "true"
      },
      {
        name  = "DD_TAGS"
        value = "account_name:${var.dd_account_name}"
      },
      {
        name  = "DD_SERVICE"
        value = var.application
      },
      {
        name  = "DD_ENV"
        value = var.environment
      }
    ],
    workingDirectory = var.working_directory
    healthCheck = {
      retries     = 3
      command     = ["CMD-SHELL", "agent health"]
      timeout     = 5
      interval    = 30
      startPeriod = 15
    }
  }
}
