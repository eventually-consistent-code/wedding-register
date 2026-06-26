output "db_host" {
  description = "RDS endpoint address (host only)."
  value       = aws_db_instance.this.address
}

output "db_endpoint" {
  description = "RDS endpoint host:port."
  value       = aws_db_instance.this.endpoint
}
