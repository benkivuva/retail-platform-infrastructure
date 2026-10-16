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

variable "repository_id" {
  description = "The name of the Artifact Registry repository"
  type        = string
  default     = "retail-platform"
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = "Docker images for the Retail Data Platform"
}