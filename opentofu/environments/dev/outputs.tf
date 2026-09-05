output "load_balancer_ip" {
  value       = module.compute.load_balancer_ip
  description = "Point your DEV DNS or HOSTS file entry to this IP"
}

output "artifact_registry_url" {
  value       = module.compute.artifact_registry_url
  description = "URL to push Windows Docker images to via gcloud"
}

output "db_private_ip" {
  value       = module.database.private_ip_address
  description = "Private SQL Server IP address inside the VPC"
}