# ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.application}-alb"
  description = "${var.application} security group"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "cloudflare_80_ipv4" {
  for_each = toset(data.cloudflare_ip_ranges.main.ipv4_cidrs)

  security_group_id = aws_security_group.alb_sg.id
  description       = "Cloudflare IPs"

  cidr_ipv4   = each.value
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "cloudflare_80_ipv6" {
  for_each = toset(data.cloudflare_ip_ranges.main.ipv6_cidrs)

  security_group_id = aws_security_group.alb_sg.id
  description       = "Cloudflare IPs"

  cidr_ipv6   = each.value
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "cloudflare_443_ipv4" {
  for_each = toset(data.cloudflare_ip_ranges.main.ipv4_cidrs)

  security_group_id = aws_security_group.alb_sg.id
  description       = "Cloudflare IPs"

  cidr_ipv4   = each.value
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "cloudflare_443_ipv6" {
  for_each = toset(data.cloudflare_ip_ranges.main.ipv6_cidrs)

  security_group_id = aws_security_group.alb_sg.id
  description       = "Cloudflare IPs"

  cidr_ipv6   = each.value
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_session_3000" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "session container port access"

  referenced_security_group_id = aws_security_group.ecs_task_sg.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web_80" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "web container port access"

  referenced_security_group_id = aws_security_group.ecs_task_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# ECS task
resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.application}-ecs-task"
  description = "${var.application} security group for ecs tasks"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "session_3000_fromt_alb" {
  security_group_id = aws_security_group.ecs_task_sg.id
  description       = "ecs task ingress from alb"

  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "web_80_from_alb" {
  security_group_id = aws_security_group.ecs_task_sg.id
  description       = "ecs task ingress from alb"

  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_internet" {
  security_group_id = aws_security_group.ecs_task_sg.id
  description       = "ecs task full egress"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# H3 Pentest needs access to reach ECS tasks
resource "aws_security_group" "pentest" {
  name        = "${var.application}-pentest"
  description = "${var.application} security group for pentest"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_sg" {
  security_group_id = aws_security_group.pentest.id
  description       = "pentest egress"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# ECS task to Valkey
resource "aws_vpc_security_group_ingress_rule" "valkey_ecs" {
  security_group_id = var.valkey_sg_id
  description       = "${var.application} ecs task access"

  referenced_security_group_id = aws_security_group.ecs_task_sg.id
  from_port                    = 6379
  ip_protocol                  = "tcp"
  to_port                      = 6379
}

# ECS task to RDS
resource "aws_vpc_security_group_ingress_rule" "rds_ecs" {
  security_group_id = var.rds_sg_id
  description       = "${var.application} ecs task access"

  referenced_security_group_id = aws_security_group.ecs_task_sg.id
  from_port                    = 1433
  ip_protocol                  = "tcp"
  to_port                      = 1433
}

# DD ECS task to RDS
resource "aws_vpc_security_group_ingress_rule" "rds_from_dd_ecs" {
  count = var.database_monitoring_enabled ? 1 : 0

  security_group_id = var.rds_sg_id
  description       = "${var.application} DD ecs task access"

  referenced_security_group_id = module.datadog_dbm[0].security_group_id
  from_port                    = 1433
  ip_protocol                  = "tcp"
  to_port                      = 1433
}

# microservices EC2 to Valkey
resource "aws_vpc_security_group_ingress_rule" "valkey_microservices_ec2" {
  count = var.microservices_ec2_enabled ? 1 : 0

  security_group_id = var.valkey_sg_id
  description       = "${var.application} microservices EC2 access"

  referenced_security_group_id = module.microservices_ec2[0].sg_id
  from_port                    = 6379
  ip_protocol                  = "tcp"
  to_port                      = 6379
}

# microservices EC2 to RDS
resource "aws_vpc_security_group_ingress_rule" "rds_microservices_ec2" {
  count = var.microservices_ec2_enabled ? 1 : 0

  security_group_id = var.rds_sg_id
  description       = "${var.application} microservices EC2 access"

  referenced_security_group_id = module.microservices_ec2[0].sg_id
  from_port                    = 1433
  ip_protocol                  = "tcp"
  to_port                      = 1433
}
