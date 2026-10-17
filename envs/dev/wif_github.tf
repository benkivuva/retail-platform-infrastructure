# Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "WIF pool for GitHub Actions CI"
}

# OIDC Provider that trusts GitHub's OIDC issuer
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"
  description                        = "OIDC provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Allow both the infra repo and the app repo
  attribute_condition = "assertion.repository == 'benkivuva/retail-platform-infrastructure' || assertion.repository == 'benkivuva/retail-data-platform'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Define both repos that need access
locals {
  github_repos = ["benkivuva/retail-platform-infrastructure", "benkivuva/retail-data-platform"]
}

# 1. Allow workflows from BOTH repos to act as the ci-runner SA
resource "google_service_account_iam_member" "ci_runner_wif" {
  for_each           = toset(local.github_repos)
  service_account_id = module.iam.service_account_names["ci-runner"]
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
}

# 2. Allow workflows from BOTH repos to generate tokens for the ci-runner SA
resource "google_service_account_iam_member" "ci_runner_token_creator" {
  for_each           = toset(local.github_repos)
  service_account_id = module.iam.service_account_names["ci-runner"]
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
}

output "wif_provider_full_id" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Full resource name of the WIF provider (goes into GitHub secret WIF_PROVIDER)"
}

output "ci_service_account_email" {
  value       = module.iam.service_account_emails["ci-runner"]
  description = "Service account email that CI impersonates (goes into GitHub secret WIF_SERVICE_ACCOUNT)"
}