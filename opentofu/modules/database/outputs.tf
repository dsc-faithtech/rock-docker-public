output "private_ip_address" {
  value       = google_sql_database_instance.rock_sql.private_ip_address
  description = "Internal IP address of the Cloud SQL Server instance"
}

output "instance_name" {
  value       = google_sql_database_instance.rock_sql.name
  description = "Name of the provisioned Cloud SQL instance"
}

output "database_name" {
  value       = google_sql_database.rock_db.name
  description = "Name of the Rock RMS database"
}
