variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "service_accounts" {
  description = "A map of service accounts to create and their roles"
  type = map(object({
    display_name = string
    description  = string
    project_roles = list(string) # Roles applied at the project level
  }))
}