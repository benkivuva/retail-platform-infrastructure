output "cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "The name of the GKE cluster"
}

output "cluster_endpoint" {
  value       = google_container_cluster.cluster.endpoint
  description = "The IP address of the GKE cluster control plane"
  sensitive   = true
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  description = "The CA certificate for the GKE cluster"
  sensitive   = true
}

output "workload_identity_pool" {
  value       = "${var.project_id}.svc.id.goog"
  description = "The Workload Identity pool for the cluster"
}