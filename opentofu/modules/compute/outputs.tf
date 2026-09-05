output "artifact_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.rock_repo.repository_id}"
  description = "Docker push destination URL for GCP Artifact Registry in Hong Kong"
}

output "load_balancer_ip" {
  value       = google_compute_global_forwarding_rule.rock_forwarding_rule.ip_address
  description = "External IP address of the Global HTTPS Load Balancer"
}

output "instance_group_manager" {
  value       = google_compute_region_instance_group_manager.rock_mig.id
  description = "Resource ID of the Managed Instance Group"
}