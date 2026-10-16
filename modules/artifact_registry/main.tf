resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.environment}-${var.repository_id}"
  description   = var.description
  format        = "DOCKER"

  # Cleanup policy: delete untagged images after 14 days
  # (intermediate build images from multi-stage builds never get tags)
  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "1209600s" # 14 days
    }
  }

  # Keep the last 10 tagged images per package; delete older ones
  cleanup_policies {
    id     = "keep-recent-tagged"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}