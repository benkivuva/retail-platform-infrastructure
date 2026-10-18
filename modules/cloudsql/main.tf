# 1. Enable required APIs for Cloud SQL (with depends_on safety)
resource "google_project_service" "cloudsql_apis" {
  for_each = toset([
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com"
  ])
  
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# 2. Allocate a private IP address range for the database
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project_id
  name          = "${var.environment}-cloudsql-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id

  depends_on = [google_project_service.cloudsql_apis]
}

# 3. Create the VPC Peering connection to Google's services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.cloudsql_apis]
}

# 4. Generate a secure random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 5. Create the Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "instance" {
  project             = var.project_id
  name                = "${var.environment}-retail-db"
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.cloudsql_apis
  ]
}

# 6. Create the Database
resource "google_sql_database" "database" {
  project  = var.project_id
  name     = "retaildb"
  instance = google_sql_database_instance.instance.name
}

# 7. Create the Database User
resource "google_sql_user" "users" {
  project  = var.project_id
  name     = "retailuser"
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
}

# 8. Create the Dagster Database
resource "google_sql_database" "dagster_db" {
  project  = var.project_id
  name     = "dagsterdb"
  instance = google_sql_database_instance.instance.name
}

# 9. Create the Dagster Database User
resource "google_sql_user" "dagster_user" {
  project  = var.project_id
  name     = "dagsteruser"
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
}