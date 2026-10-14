variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "buckets" {
  description = "A map of bucket configurations"
  type = map(object({
    name_suffix        = string
    versioning_enabled = bool
    lifecycle_age_days = number
    storage_class      = string
  }))
}