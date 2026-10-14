output "service_account_emails" {
  value       = { for k, v in google_service_account.service_accounts : k => v.email }
  description = "A map of service account keys to their email addresses"
}

output "service_account_names" {
  value       = { for k, v in google_service_account.service_accounts : k => v.name }
  description = "A map of service account keys to their fully qualified names"
}