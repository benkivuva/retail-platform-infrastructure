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

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The CIDR block for the GKE control plane"
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_service_account_email" {
  description = "The email of the minimal service account for GKE nodes"
  type        = string
}