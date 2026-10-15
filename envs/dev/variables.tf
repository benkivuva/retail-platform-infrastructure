variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo, used to restrict WIF access"
  type        = string
}

variable "argocd_chart_version" {
  description = "Version of the argo-cd Helm chart to install"
  type        = string
  default     = "10.10.3"
}

variable "argocd_helm_repo_url" {
  description = "URL of the ArgoCD Helm chart repository"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}
