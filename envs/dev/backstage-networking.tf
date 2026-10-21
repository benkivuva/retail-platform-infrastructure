resource "google_compute_address" "backstage_ip" {
  name   = "backstage-static-ip"
  region = var.region
}

output "backstage_ip_address" {
  value       = google_compute_address.backstage_ip.address
  description = "The static IP for the Backstage Ingress"
}
