resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = "${var.environment}-${each.key}"
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
}

locals {
  sa_roles = flatten([
    for sa_key, sa in var.service_accounts : [
      for role in sa.project_roles : {
        sa_key = sa_key
        role   = role
      }
    ]
  ])
}

resource "google_project_iam_member" "sa_roles" {
  for_each = { for item in local.sa_roles : "${item.sa_key}-${item.role}" => item }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"
}