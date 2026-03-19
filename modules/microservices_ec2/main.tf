# Private key is in 1password
resource "aws_key_pair" "my_app" {
  key_name   = var.application
  public_key = var.public_key
}

resource "aws_instance" "microservices_ec2" {
  # Hardcoding this for now. Hopefully this EC2 instance won't exist in a month
  ami                    = var.ami # Windows_Server-2025-English-Full-Base-2025.06.11
  instance_type          = "t3.large"
  iam_instance_profile   = aws_iam_instance_profile.microservices_ec2_profile.name
  vpc_security_group_ids = [aws_security_group.microservices_ec2.id]
  subnet_id              = data.aws_subnets.private.ids[0]
  monitoring             = true

  # currently manually created in AWS UI
  key_name = aws_key_pair.my_app.key_name

  user_data = <<EOF
Get-SSMParametersByPath -Path "${var.parameter_store_prefix}" -WithDecryption $true |
ForEach-Object {
  $envKey = ($_.Name -split "/")[-1]
  $envValue = $_.Value

  [Environment]::SetEnvironmentVariable($envKey, $envValue, "Machine")
}
  EOF

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 100
  }

  tags = {
    Name = "${var.application}-microservices"
  }
}

# Same errors will be also sent to Sentry. We can remove this if there is no value having errors in DD as well
resource "aws_cloudwatch_log_group" "microservices_ec2_errors" {
  name              = "/ec2/${var.application}/developer_errors"
  retention_in_days = 30
}

resource "aws_lambda_permission" "microservices_ec2_errors" {
  action        = "lambda:InvokeFunction"
  function_name = var.datadog_log_forwarder_lambda
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.microservices_ec2_errors.arn
}

resource "aws_cloudwatch_log_subscription_filter" "microservices_ec2_errors" {
  name           = "datadog_log_subscription_filter"
  log_group_name = "/ec2/${var.application}/developer_errors"
  # This function was created outside of TF
  destination_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.datadog_log_forwarder_lambda}"
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.microservices_ec2_errors]
}

# Application logs
resource "aws_cloudwatch_log_group" "microservices_ec2_application" {
  name              = "/ec2/${var.application}/application"
  retention_in_days = 30
}

resource "aws_lambda_permission" "microservices_ec2_application" {
  action        = "lambda:InvokeFunction"
  function_name = var.datadog_log_forwarder_lambda
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.microservices_ec2_application.arn
}

resource "aws_cloudwatch_log_subscription_filter" "microservices_ec2_application" {
  name           = "datadog_log_subscription_filter"
  log_group_name = "/ec2/${var.application}/application"
  # This function was created outside of TF
  destination_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.datadog_log_forwarder_lambda}"
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.microservices_ec2_application]
}
