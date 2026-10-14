# 1. Create the VPC
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false # We want to control our subnets manually
  routing_mode            = "GLOBAL"
}

# 2. Create the Subnet with Secondary IP Ranges for GKE
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = "10.0.0.0/20" # Main subnet for nodes
  region        = var.region
  network       = google_compute_network.vpc.id

  # Secondary range for Kubernetes Pods
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  # Secondary range for Kubernetes Services
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# 3. Firewall Rule: Allow Internal Traffic
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# 4. Firewall Rule: Allow SSH via IAP (Identity-Aware Proxy)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}