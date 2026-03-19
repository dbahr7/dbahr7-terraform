output "sg_id" {
  value       = aws_security_group.microservices_ec2.id
  description = "The ID of the SG for the EC2 instance"
}
