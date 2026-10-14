provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Networking Module ---
module "networking" {
  source = "../../modules/networking"

  project_id   = var.project_id
  region       = var.region
  network_name = "retail-platform-prod-vpc"
}

# --- GCS Module ---
module "gcs" {
  source = "../../modules/gcs"

  project_id  = var.project_id
  region      = var.region
  environment = "prod"

  buckets = {
    "raw-data" = {
      name_suffix        = "raw-data"
      versioning_enabled = true
      lifecycle_age_days = 90
      storage_class      = "STANDARD"
    }
    "dbt-artifacts" = {
      name_suffix        = "dbt-artifacts"
      versioning_enabled = true
      lifecycle_age_days = 30
      storage_class      = "STANDARD"
    }
    "temp-processing" = {
      name_suffix        = "temp-processing"
      versioning_enabled = false
      lifecycle_age_days = 1
      storage_class      = "STANDARD"
    }
  }
}

# --- BigQuery Module ---
module "bigquery" {
  source = "../../modules/bigquery"

  project_id  = var.project_id
  region      = var.region
  environment = "prod"

  datasets = {
    "raw"          = { description = "Raw data loaded from source systems.",              default_table_expiry = 0, delete_contents_on_destroy = false }
    "staging"      = { description = "Cleaned, typed, and renamed data.",                 default_table_expiry = 0, delete_contents_on_destroy = false }
    "intermediate" = { description = "Business logic applied. Not exposed to BI.",        default_table_expiry = 0, delete_contents_on_destroy = false }
    "marts"        = { description = "Star schema for BI.",                                default_table_expiry = 0, delete_contents_on_destroy = false }
    "ai_views"     = { description = "PII-free views for the AI assistant. SELECT only.", default_table_expiry = 0, delete_contents_on_destroy = false }
  }
}

# --- IAM Module ---
module "iam" {
  source = "../../modules/iam"

  project_id  = var.project_id
  environment = "prod"

  service_accounts = {
    "dagster-runner" = {
      display_name  = "Dagster Orchestrator"
      description   = "Used by Dagster to run dbt and load data"
      project_roles = ["roles/bigquery.dataEditor", "roles/bigquery.jobUser", "roles/storage.objectAdmin"]
    }
    "flask-app" = {
      display_name  = "Flask Dashboard"
      description   = "Read-only access for the dashboard"
      project_roles = ["roles/bigquery.dataViewer", "roles/bigquery.jobUser"]
    }
    "ai-assistant" = {
      display_name  = "AI Assistant"
      description   = "Queries AI views, reads secrets"
      project_roles = ["roles/bigquery.dataViewer", "roles/bigquery.jobUser", "roles/secretmanager.secretAccessor"]
    }
    "gke-nodes" = {
      display_name  = "GKE Node Service Account"
      description   = "Minimal SA for GKE node VMs"
      project_roles = ["roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/artifactregistry.reader"]
    }
  }
}

# --- GKE Module (prod sizing) ---
module "gke" {
  source = "../../modules/gke"

  project_id             = var.project_id
  region                 = var.region
  environment            = "prod"
  network_name           = module.networking.network_name
  subnet_name            = module.networking.subnet_name
  master_ipv4_cidr_block = "172.17.0.0/28"

  node_service_account_email = module.iam.service_account_emails["gke-nodes"]

  master_authorized_cidrs = [
    { cidr_block = "10.0.0.0/20",       display_name = "vpc-subnet" },
    { cidr_block = "105.160.99.225/32", display_name = "my-workstation" },
  ]

  # Prod sizing — bigger nodes, more of them
  standard_machine_type = "e2-standard-2"
  standard_disk_size_gb = 100
  standard_min_nodes    = 2
  standard_max_nodes    = 6

  spot_machine_type = "e2-medium"
  spot_disk_size_gb = 50
  spot_min_nodes    = 0
  spot_max_nodes    = 10
}