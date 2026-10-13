terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "retail-platform-tf-state"
    prefix = "dev"
  }
}
