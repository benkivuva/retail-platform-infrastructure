resource "google_container_cluster" "cluster" {
  name     = "${var.environment}-retail-platform-gke"
  location = var.region
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnet_name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_cidrs
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing        { disabled = false }
    horizontal_pod_autoscaling { disabled = false }
  }

  maintenance_policy {
    recurring_window {
      start_time = "2026-01-01T02:00:00Z"
      end_time   = "2026-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  deletion_protection = false
}

resource "google_container_node_pool" "standard" {
  name       = "${var.environment}-standard-pool"
  cluster    = google_container_cluster.cluster.id

  autoscaling {
    total_min_node_count = var.standard_min_nodes
    total_max_node_count = var.standard_max_nodes
    location_policy      = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.standard_machine_type
    disk_size_gb    = var.standard_disk_size_gb
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    service_account = var.node_service_account_email

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      pool        = "standard"
      environment = var.environment
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  depends_on = [google_container_cluster.cluster]
}

resource "google_container_node_pool" "spot" {
  name    = "${var.environment}-spot-pool"
  cluster = google_container_cluster.cluster.id

  autoscaling {
    total_min_node_count = var.spot_min_nodes
    total_max_node_count = var.spot_max_nodes
    location_policy      = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.spot_machine_type
    disk_size_gb    = var.spot_disk_size_gb
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    spot            = true
    service_account = var.node_service_account_email

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      pool        = "spot"
      environment = var.environment
    }

    taint {
      key    = "cloud.google.com/gke-spot"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  depends_on = [google_container_cluster.cluster]
}