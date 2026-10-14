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
  description = "CIDR block for the GKE control plane"
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_service_account_email" {
  description = "The email of the minimal service account for GKE nodes"
  type        = string
}

# --- Master authorized networks ---
variable "master_authorized_cidrs" {
  description = "List of CIDR blocks allowed to reach the cluster API server"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    { cidr_block = "10.0.0.0/20", display_name = "vpc-subnet" }
  ]
}

# --- Standard node pool ---
variable "standard_machine_type" {
  description = "Machine type for the standard (on-demand) node pool"
  type        = string
  default     = "e2-medium"
}

variable "standard_disk_size_gb" {
  description = "Boot disk size in GB for the standard node pool"
  type        = number
  default     = 50
}

variable "standard_min_nodes" {
  description = "Total minimum nodes for the standard pool"
  type        = number
  default     = 1
}

variable "standard_max_nodes" {
  description = "Total maximum nodes for the standard pool"
  type        = number
  default     = 3
}

# --- Spot node pool ---
variable "spot_machine_type" {
  description = "Machine type for the spot node pool"
  type        = string
  default     = "e2-small"
}

variable "spot_disk_size_gb" {
  description = "Boot disk size in GB for the spot node pool"
  type        = number
  default     = 30
}

variable "spot_min_nodes" {
  description = "Total minimum nodes for the spot pool"
  type        = number
  default     = 0
}

variable "spot_max_nodes" {
  description = "Total maximum nodes for the spot pool"
  type        = number
  default     = 5
}