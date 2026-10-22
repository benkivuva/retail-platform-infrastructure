output "connection_name" {
  value       = google_sql_database_instance.instance.connection_name
  description = "The connection name of the Cloud SQL instance"
}

output "private_ip_address" {
  value       = google_sql_database_instance.instance.private_ip_address
  description = "The private IP address of the database"
}

output "db_name" {
  value = google_sql_database.database.name
}

output "db_user" {
  value = google_sql_user.users.name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "dagster_db_name" {
  value = google_sql_database.dagster_db.name
}

output "dagster_db_user" {
  value = google_sql_user.dagster_user.name
}
output "backstage_db_name" {
  value = google_sql_database.backstage_db.name
}

output "backstage_db_user" {
  value = google_sql_user.backstage_user.name
}
