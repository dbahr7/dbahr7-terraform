resource "aws_security_group" "database_bridge_nlb" {
  name        = "${var.application}-database-bridge-nlb"
  description = "${var.application} database bridge NLB security group"
  vpc_id      = data.aws_vpc.main.id
}

locals {
  # Taken from the "United States (North Virginia)" list in https://www.metabase.com/docs/latest/cloud/ip-addresses-to-whitelist

  metabase_ips = toset([
    "x.x.x.126/32",
    "x.x.x.157/32",
    "x.x.x.169/32"
  ])
  # Taken from the "US East (AWS)" list in https://domo-support.domo.com/s/article/360043630093
  domo_ips = toset([
    "x.x.x.64/27",
    "x.x.x.122/32",
    "x.x.x.194/32",
    "x.x.x.167/32",
    "x.x.x.237/32",
    "x.x.x.248/32"
  ])
}

resource "aws_vpc_security_group_ingress_rule" "metabase_to_nlb" {
  for_each = local.metabase_ips

  security_group_id = aws_security_group.database_bridge_nlb.id
  description       = "metabase ${each.key}"

  cidr_ipv4   = each.value
  ip_protocol = "tcp"
  from_port   = 422
  to_port     = 422
}

resource "aws_vpc_security_group_ingress_rule" "domo_to_nlb" {
  for_each = local.domo_ips

  security_group_id = aws_security_group.database_bridge_nlb.id
  description       = "domo ${each.key}"

  cidr_ipv4   = each.value
  ip_protocol = "tcp"
  from_port   = 422
  to_port     = 422
}

resource "aws_vpc_security_group_egress_rule" "nlb_to_database_bridge" {
  security_group_id = aws_security_group.database_bridge_nlb.id
  description       = "database_bridge access"

  referenced_security_group_id = aws_security_group.database_bridge_ecs_task.id
  ip_protocol                  = "tcp"
  from_port                    = 2222
  to_port                      = 2222
}

resource "aws_vpc_security_group_egress_rule" "nlb_to_database_bridge_ping" {
  security_group_id = aws_security_group.database_bridge_nlb.id
  description       = "database_bridge ping access"

  referenced_security_group_id = aws_security_group.database_bridge_ecs_task.id
  ip_protocol                  = "icmp"
  from_port                    = 0
  to_port                      = 0
}

resource "aws_security_group" "database_bridge_ecs_task" {
  name        = "${var.application}-database-bridge-ecs-task"
  description = "${var.application} database bridge security group for ecs tasks"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "port_2222_from_nlb" {
  security_group_id = aws_security_group.database_bridge_ecs_task.id
  description       = "ecs task ingress from nlb"

  referenced_security_group_id = aws_security_group.database_bridge_nlb.id
  ip_protocol                  = "tcp"
  from_port                    = 2222
  to_port                      = 2222
}

resource "aws_vpc_security_group_ingress_rule" "ping_from_nlb" {
  security_group_id = aws_security_group.database_bridge_ecs_task.id
  description       = "ecs task ping from nlb"

  referenced_security_group_id = aws_security_group.database_bridge_nlb.id
  ip_protocol                  = "icmp"
  from_port                    = 0
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_internet" {
  security_group_id = aws_security_group.database_bridge_ecs_task.id
  description       = "ecs task full egress"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "rds_ecs" {
  security_group_id = var.rds_sg_id
  description       = "${var.application} database bridge ecs task access"

  referenced_security_group_id = aws_security_group.database_bridge_ecs_task.id
  ip_protocol                  = "tcp"
  from_port                    = 1433
  to_port                      = 1433
}
