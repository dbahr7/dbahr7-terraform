resource "aws_lb" "database_bridge" {
  name               = "${var.application}-database-bridge"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.database_bridge_nlb.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "database_bridge" {
  name        = "${var.application}-database-bridge"
  target_type = "ip"
  port        = 422
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_lb_listener" "database_bridge" {
  load_balancer_arn = aws_lb.database_bridge.arn
  port              = "422"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.database_bridge.arn
  }
}
