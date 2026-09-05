output "network_id" {
  value       = google_compute_network.vpc.id
  description = "VPC Network ID"
}

output "network_name" {
  value       = google_compute_network.vpc.name
  description = "VPC Network Name"
}

output "public_subnet_id" {
  value       = google_compute_subnetwork.public.id
  description = "ID of the Hong Kong public subnetwork"
}

output "private_subnet_id" {
  value       = google_compute_subnetwork.private.id
  description = "ID of the Hong Kong private compute subnetwork"
}

output "database_subnet_id" {
  value       = google_compute_subnetwork.database.id
  description = "ID of the Hong Kong database subnetwork"
}
