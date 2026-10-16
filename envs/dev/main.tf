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
  environment = "dev"

  datasets = {
    "raw" = {
      description                = "Raw data loaded from source systems. Never modified. Pristine for reproducibility."
      default_table_expiry       = 0
      delete_contents_on_destroy = true
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

# --- IAM Module ---
module "iam" {
  source = "../../modules/iam"

  project_id  = var.project_id
  environment = "dev"

  service_accounts = {
    "dagster-runner" = {
      display_name = "Dagster Orchestrator"
      description  = "Service account used by Dagster to run dbt models and load data"
      project_roles = [
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
        "roles/storage.objectAdmin"
      ]
    }
    "flask-app" = {
      display_name = "Flask Dashboard"
      description  = "Service account used by the Flask application to read data"
      project_roles = [
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser"
      ]
    }
    "ai-assistant" = {
      display_name = "AI Assistant"
      description  = "Service account used by the AI assistant to query AI views and access secrets"
      project_roles = [
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser",
        "roles/secretmanager.secretAccessor"
      ]
    }
    "gke-nodes" = {
      display_name = "GKE Node Service Account"
      description  = "Minimal SA for GKE node VMs. Not used by pods."
      project_roles = [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/artifactregistry.reader"
      ]
    }
    # NOTE: This SA runs Terraform for the whole stack, so it needs broad
    # service-level admin roles. In a larger org, you would split this into
    # multiple runners (infra, data, apps) each with narrower scope.
    "ci-runner" = {
      display_name = "GitHub Actions CI Runner"
      description  = "Service account assumed by GitHub Actions via Workload Identity Federation"
      project_roles = [
        "roles/compute.admin",
        "roles/container.admin",
        "roles/iam.serviceAccountAdmin",
        "roles/resourcemanager.projectIamAdmin",
        "roles/storage.admin",
        "roles/bigquery.admin",
        "roles/secretmanager.admin",
        "roles/iam.workloadIdentityPoolAdmin",
        "roles/artifactregistry.admin"
      ]
    }
  }
}

# --- GKE Module ---
module "gke" {
  source = "../../modules/gke"

  project_id             = var.project_id
  region                 = var.region
  environment            = "dev"
  network_name           = module.networking.network_name
  subnet_name            = module.networking.subnet_name
  master_ipv4_cidr_block = "172.16.0.0/28"

  node_service_account_email = module.iam.service_account_emails["gke-nodes"]

  master_authorized_cidrs = [
    { cidr_block = "10.0.0.0/20",       display_name = "vpc-subnet" },
    { cidr_block = "105.160.32.16/32", display_name = "my-workstation" },
  ]
}

# --- Artifact Registry Module ---
module "artifact_registry" {
  source = "../../modules/artifact_registry"

  project_id  = var.project_id
  region      = var.region
  environment = "dev"
}