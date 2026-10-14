resource "google_service_account_iam_member" "dagster_ksa_binding" {
  service_account_id = module.iam.service_account_names["dagster-runner"]
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[dagster/dagster-ksa]"

  depends_on = [module.gke]
}

resource "google_service_account_iam_member" "flask_ksa_binding" {
  service_account_id = module.iam.service_account_names["flask-app"]
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[flask/flask-ksa]"

  depends_on = [module.gke]
}

resource "google_service_account_iam_member" "ai_ksa_binding" {
  service_account_id = module.iam.service_account_names["ai-assistant"]
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[ai/ai-ksa]"

  depends_on = [module.gke]
}