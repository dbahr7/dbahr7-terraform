output "sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "The ID of the SG for provisioned RDS cluster"
}

output "host" {
  value       = aws_db_instance.mssql.address
  description = "Host address of the mssql instance"
}
