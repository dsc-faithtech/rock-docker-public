# 1. Private Service Access for Internal VPC Peering with Cloud SQL
resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.project_id
  name          = "rockrms-${var.environment}-sql-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# 2. Cloud SQL for SQL Server Instance in Hong Kong
resource "google_sql_database_instance" "rock_sql" {
  project             = var.project_id
  name                = "rockrms-${var.environment}-db"
  region              = var.region
  database_version    = "SQLSERVER_2019_STANDARD"
  root_password       = var.db_password
  deletion_protection = var.environment == "prod" ? true : false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = 50
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false # Isolated: No public IP
      private_network = var.network_id
    }

    backup_configuration {
      enabled    = true
      start_time = "18:00" # UTC time (02:00 AM HKT)
    }
  }
}

# 3. Default Rock RMS Database
resource "google_sql_database" "rock_db" {
  project  = var.project_id
  name     = "Rock"
  instance = google_sql_database_instance.rock_sql.name
}
