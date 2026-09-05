# 1. Custom VPC Network
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "rockrms-${var.environment}-vpc"
  auto_create_subnetworks = false
}

# 2. Subnets in Hong Kong (asia-east2)
resource "google_compute_subnetwork" "public" {
  project                  = var.project_id
  name                     = "rockrms-${var.environment}-public-hk"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.public_subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private" {
  project                  = var.project_id
  name                     = "rockrms-${var.environment}-private-hk"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.private_subnet_cidr
  private_ip_google_access = true # Enables Google APIs without public IPs
}

resource "google_compute_subnetwork" "database" {
  project                  = var.project_id
  name                     = "rockrms-${var.environment}-db-hk"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.db_subnet_cidr
  private_ip_google_access = true
}

# 3. Cloud NAT for Private Instances (Outgoing Internet Access for Windows Updates / Docker pulls)
resource "google_compute_router" "router" {
  project = var.project_id
  name    = "rockrms-${var.environment}-router-hk"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "rockrms-${var.environment}-nat-hk"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# 4. Firewall Rules
# Allow Health Checks and Load Balancer traffic to private instances
resource "google_compute_firewall" "allow_lb_healthcheck" {
  project     = var.project_id
  name        = "rockrms-${var.environment}-allow-lb-healthcheck"
  network     = google_compute_network.vpc.name
  description = "Allow Google Cloud Load Balancer and Health Checks to reach Windows web instances"

  direction = "INGRESS"
  priority  = 1000

  # GCP Global Load Balancer health check probe IP ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Allow internal network traffic (Web to Cloud SQL Server)
resource "google_compute_firewall" "allow_internal" {
  project     = var.project_id
  name        = "rockrms-${var.environment}-allow-internal"
  network     = google_compute_network.vpc.name
  description = "Allow internal traffic within the VPC"

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [var.vpc_cidr]

  allow {
    protocol = "tcp"
    ports    = ["1433", "80", "443"]
  }
}
