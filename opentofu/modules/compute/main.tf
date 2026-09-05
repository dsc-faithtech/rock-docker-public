# 1. Artifact Registry for Storing Rock RMS Windows Containers
resource "google_artifact_registry_repository" "rock_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "rockrms-${var.environment}-repo"
  description   = "Docker repository for Rock RMS Windows container images"
  format        = "DOCKER"
}

# 2. Instance Template for Windows Compute Engine Nodes
resource "google_compute_instance_template" "rock_template" {
  name_prefix  = "rockrms-${var.environment}-template-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "windows-cloud/windows-2022-core" # Windows Server Core for container hosting
    auto_delete  = true
    boot         = true
    disk_size_gb = 100
    disk_type    = "pd-ssd"
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
    # No public IP assigned directly to Compute instances (uses Cloud NAT)
  }

  metadata = {
    sysprep-specialize-script-ps1 = <<-EOT
      # Bootstrap script: Install Containers feature & Configure Docker
      Install-WindowsFeature -Name Containers -IncludeAllSubFeature
      Restart-Computer -Force
    EOT
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Regional Managed Instance Group (MIG) for High Availability across Hong Kong Zones
resource "google_compute_region_instance_group_manager" "rock_mig" {
  name               = "rockrms-${var.environment}-mig"
  region             = var.region
  base_instance_name = "rockrms-node"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.rock_template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.http_check.id
    initial_delay_sec = 600 # Extended startup window for Windows initialization
  }
}

# 4. Regional Health Check
resource "google_compute_region_health_check" "http_check" {
  name   = "rockrms-${var.environment}-health-check"
  region = var.region

  http_health_check {
    port         = 80
    request_path = "/Start.aspx"
  }
}

# 5. External HTTPS Load Balancer (Global Backend Service)
resource "google_compute_backend_service" "rock_backend" {
  name                  = "rockrms-${var.environment}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  health_checks         = [google_compute_region_health_check.http_check.id]

  backend {
    group          = google_compute_region_instance_group_manager.rock_mig.instance_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "rock_url_map" {
  name            = "rockrms-${var.environment}-url-map"
  default_service = google_compute_backend_service.rock_backend.id
}

resource "google_compute_target_http_proxy" "rock_http_proxy" {
  name    = "rockrms-${var.environment}-http-proxy"
  url_map = google_compute_url_map.rock_url_map.id
}

resource "google_compute_global_forwarding_rule" "rock_forwarding_rule" {
  name       = "rockrms-${var.environment}-lb-forwarding-rule"
  target     = google_compute_target_http_proxy.rock_http_proxy.id
  port_range = "80"
}