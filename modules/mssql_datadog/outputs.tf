output "security_group_id" {
  value       = aws_security_group.datadog_dbm.id
  description = "The SG ID of the DD agent task"
}
