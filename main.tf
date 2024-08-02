terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.51.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "google" {
  credentials = file("service-account.json")
  project     = "${local.project}"
  region      = "southamerica-east1"
}

locals {
  project = "test-gcp-terraform-431318"
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = "southamerica-east1"
  repository_id = "testing-terraform"
  description   = "my APIs"
  format        = "docker"
}


resource "google_cloud_run_service" "instance" {
  name     = "go-api"
  location = google_artifact_registry_repository.my-repo.location

  template {
    spec {
      containers {
        image = "gcr.io/southamerica-east1-docker.pkg.dev/test-gcp-terraform-431318/testing-terraform/api"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

output "resultado" {
  value = google_cloud_run_service.instance.status[0].url
}
