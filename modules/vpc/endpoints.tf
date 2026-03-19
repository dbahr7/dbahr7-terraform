resource "aws_security_group" "endpoint" {
  name        = "${var.application}-${var.environment}-${var.purpose}-vpc-endpoint"
  vpc_id      = aws_vpc.main.id
  description = "${var.application}-${var.environment} ${var.purpose} VPC endpoint security group"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

locals {
  service_name_prefix = "com.amazonaws.${var.region}"
  services = [
    "ecs-agent",
    "ecs-telemetry",
    "ecs",
    # SSM https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
    "ssm",
    "ec2messages",
    "ssmmessages",
    # KMS https://docs.aws.amazon.com/kms/latest/developerguide/kms-vpc-endpoint.html
    "kms",
    # CloudWatch Logs https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch-logs-and-interface-VPC.html
    "logs",
    # ECR https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
    "ecr.api",
    "ecr.dkr",
    # CloudWatch Events https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/cloudwatch-events-and-interface-VPC.html
    "events",
    # CloudWatch https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch-and-interface-VPC.html
    "monitoring"
  ]
}

resource "aws_vpc_endpoint" "endpoint" {
  for_each = toset(local.services)

  vpc_id            = aws_vpc.main.id
  service_name      = "${local.service_name_prefix}.${each.value}"
  vpc_endpoint_type = "Interface"
  ip_address_type   = "ipv4"

  subnet_ids         = [for s in aws_subnet.private-compute : s.id]
  security_group_ids = [aws_security_group.endpoint.id]

  private_dns_enabled = true

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name = "${each.value}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "${local.service_name_prefix}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private-compute.id,
    aws_route_table.private-data.id
  ]

  tags = {
    Name = "s3"
  }
}
