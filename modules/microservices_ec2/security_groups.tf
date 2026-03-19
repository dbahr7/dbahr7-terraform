# microservices EC2 instance
resource "aws_security_group" "microservices_ec2" {
  name        = "${var.application}-microservices-ec2"
  description = "${var.application} microservices EC2 security group"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "microservices_ec2_internet" {
  security_group_id = aws_security_group.microservices_ec2.id
  description       = "EC2 full egress"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
