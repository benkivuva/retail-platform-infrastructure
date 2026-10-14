# Create one BigQuery dataset per entry in the `datasets` map
resource "google_bigquery_dataset" "datasets" {
  for_each = var.datasets

  dataset_id    = "${var.environment}_${each.key}"
  friendly_name = "${var.environment} - ${each.key}"
  description   = each.value.description
  location      = var.region

  # Safety: Prevent accidental deletion of a dataset containing tables
  delete_contents_on_destroy = each.value.delete_contents_on_destroy

  # Cost: Automatically expire tables (0 = never expire)
  default_table_expiration_ms = each.value.default_table_expiry > 0 ? each.value.default_table_expiry * 86400000 : null

  labels = {
    environment = var.environment
    layer       = each.key
    managed_by  = "terraform"
  }
}