provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Networking Module ---
module "networking" {
  source = "../../modules/networking"

  project_id   = var.project_id
  region       = var.region
  network_name = "retail-platform-dev-vpc"
}

# --- GCS Module ---
module "gcs" {
  source = "../../modules/gcs"

  project_id  = var.project_id
  region      = var.region
  environment = "dev"

  buckets = {
    "raw-data" = {
      name_suffix        = "raw-data"
      versioning_enabled = true
      lifecycle_age_days = 30
      storage_class      = "STANDARD"
    }
    "dbt-artifacts" = {
      name_suffix        = "dbt-artifacts"
      versioning_enabled = false
      lifecycle_age_days = 7
      storage_class      = "STANDARD"
    }
    "temp-processing" = {
      name_suffix        = "temp-processing"
      versioning_enabled = false
      lifecycle_age_days = 1      # Temp files vanish after a day
      storage_class      = "STANDARD"
    }
  }
}

# --- BigQuery Module ---
module "bigquery" {
  source = "../../modules/bigquery"

  project_id  = var.project_id
  region      = var.region
  environment = "dev"

  datasets = {
    "raw" = {
      description                = "Raw data loaded from source systems. Never modified. Pristine for reproducibility."
      default_table_expiry       = 0
      delete_contents_on_destroy = true # Dev only: allow clean teardown
    }
    "staging" = {
      description                = "Cleaned, typed, and renamed data. One model per source table."
      default_table_expiry       = 0
      delete_contents_on_destroy = true
    }
    "intermediate" = {
      description                = "Business logic applied (order totals, delivery timing). Not exposed to BI."
      default_table_expiry       = 0
      delete_contents_on_destroy = true
    }
    "marts" = {
      description                = "Star schema: dimensions, facts, and the metrics_daily semantic layer."
      default_table_expiry       = 0
      delete_contents_on_destroy = true
    }
    "ai_views" = {
      description                = "PII-free, aggregated views for the governed AI assistant. Only SELECT is permitted."
      default_table_expiry       = 0
      delete_contents_on_destroy = true
    }
  }
}