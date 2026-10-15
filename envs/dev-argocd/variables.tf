variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "dev-retail-platform-gke"
}

variable "argocd_chart_version" {
  description = "Version of the argo-cd Helm chart"
  type        = string
}

variable "argocd_helm_repo_url" {
  description = "URL of the ArgoCD Helm chart repository"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}