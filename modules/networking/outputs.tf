output "network_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC network"
}

output "subnet_id" {
  value       = google_compute_subnetwork.subnet.id
  description = "The ID of the subnet"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet.name
  description = "The name of the subnet"
}