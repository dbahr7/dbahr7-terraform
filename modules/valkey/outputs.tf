output "sg_id" {
  value       = aws_security_group.valkey_sg.id
  description = "The ID of the SG for provisioned Valkey cluster"
}
