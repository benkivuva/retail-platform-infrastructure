resource "google_storage_bucket" "buckets" {
  for_each = var.buckets

  name          = "${var.project_id}-${var.environment}-${each.value.name_suffix}"
  location      = var.region
  storage_class = each.value.storage_class
  force_destroy = false

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = each.value.versioning_enabled
  }

  lifecycle_rule {
    condition {
      age = each.value.lifecycle_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age        = 30
      with_state = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}