terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }

    doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
      version = "~> 0.0.2"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "nikolasrieble"

    workspaces {
      name = "verbose-garbanzo"
    }
  }
}

provider "doormat" {}

variable "project_id" {
  type = string
}

data "doormat_gcp_credentials" "creds" {
  provider = doormat

  service_account = "nikolasrieble@hc-1eee1e0fde6f4d6cb76f7157200.iam.gserviceaccount.com"
  project_id      = var.project_id
}

provider "google" {
  access_token = data.doormat_gcp_credentials.creds.access_token
  project      = var.project_id
}

resource "google_storage_bucket" "test-bucket" {
  project = var.project_id
  name          = "test-bucket"
  location      = "EU"
  uniform_bucket_level_access = true
}