# Filename: main.tf
variable "project" {
  default = "microfrontend-app"
  description = "The Goggle Cloud project name"
}

variable "service" {
  default = "importmap-deployer"
  description = "The name of the service"
}

variable "location" {
  default = "us-east-1"
}

variable "bucket" {
  default = "importmap"
}


# Configure GCP project
provider "google" {
  project = var.project
}
# Deploy image to Cloud Run
# See: https://www.terraform.io/docs/providers/google/r/cloud_run_service.html
resource "google_cloud_run_service" "importmap-deployer" {
  name     = var.service
  location = var.location
  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/${var.service}"
      }
    }

    metadata {
      annotations = {
        # ensure max 1 to avoid concurrency issues when updating storage
        "autoscaling.knative.dev/maxScale" = "1"
      }
    }    
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
# Create public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
# Enable public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.mywebapp.location
  project     = google_cloud_run_service.mywebapp.project
  service     = google_cloud_run_service.mywebapp.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_storage_bucket" "image-store" {
  name     = var.bucket
  location = var.location
}

# Return service URL
output "url" {
  value = "${google_cloud_run_service.mywebapp.status[0].url}"
}