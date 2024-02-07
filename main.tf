resource "null_resource" "hello_world" {
  provisioner "local-exec" {
    command = "echo hello world!!"
  }
}

resource "null_resource" "hello_world_part_2" {
  provisioner "local-exec" {
    command = "echo ${var.greetings}!"
  }
}

resource "null_resource" "dont_hack_me" {
  provisioner "local-exec" {
    command = "echo My password is: ${var.password}"
  }
}

module "module-1" {
  source  = "miguelhrocha/helloworld/aws"
  version = "1.0.0"
  # insert required variables here
  password = "ZAQ!xsw2"
}
  
module "curated-module" {
  source  = "briancain/helloworld/aws"
  version = "2020.4.21"
  # insert required variables here
  password = "ZAQ!xsw2"
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_2_minutes" {
  depends_on = [null_resource.previous]

  create_duration = "2m"
}

# This resource will create (at least) 2 minutes after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_2_minutes]
}

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

data "doormat_gcp_credentials" "creds" {
  provider = doormat

  service_account = "nikolasrieble@hc-1eee1e0fde6f4d6cb76f7157200.iam.gserviceaccount.com"
  project_id      = "tf-onprem-dev"
}

provider "google" {
  access_token = data.doormat_gcp_credentials.creds.access_token
  project      = "tf-onprem-dev"
}

module "cloud-storage_example_simple_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//examples/simple_bucket"
  version = "5.0.0"
  project_id = "tf-onprem-dev"
}