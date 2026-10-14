output "dataset_ids" {
  value       = { for k, v in google_bigquery_dataset.datasets : k => v.dataset_id }
  description = "A map of dataset keys to their BigQuery dataset IDs"
}