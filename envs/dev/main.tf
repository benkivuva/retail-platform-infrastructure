provider "google" {
  project = var.project_id
  region  = var.region
}

# Call the Networking Module
module "networking" {
  source = "../../modules/networking"

  project_id   = var.project_id
  region       = var.region
  network_name = "retail-platform-dev-vpc"
}