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

variable "datasets" {
  description = "A map of dataset configurations (name -> description)"
  type = map(object({
    description           = string
    default_table_expiry  = number # in days; 0 means no expiry
    delete_contents_on_destroy = bool
  }))
}