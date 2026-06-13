output "db_endpoints" {
  description = "Map of service name -> RDS connection endpoint (host:port)"
  value       = { for k, v in aws_db_instance.main : k => v.endpoint }
}

output "db_addresses" {
  description = "Map of service name -> RDS hostname (no port)"
  value       = { for k, v in aws_db_instance.main : k => v.address }
}

output "rds_security_group_id" {
  description = "Security group ID attached to all RDS instances"
  value       = aws_security_group.rds.id
}
