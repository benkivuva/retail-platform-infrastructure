output "bucket_names" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.name }
  description = "A map of bucket keys to their full GCS names"
}

output "bucket_urls" {
  value       = { for k, v in google_storage_bucket.buckets : k => "gs://${v.name}" }
  description = "A map of bucket keys to their gs:// URLs"
}