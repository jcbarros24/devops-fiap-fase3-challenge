output "endpoints" {
  description = "Mapa serviço -> endpoint (host:port) do RDS correspondente."
  value       = { for k, v in aws_db_instance.this : k => v.endpoint }
}

output "db_names" {
  value = { for k, v in aws_db_instance.this : k => v.db_name }
}
