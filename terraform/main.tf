terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Buckets do Cloud Storage
resource "google_storage_bucket" "input_bucket" {
  name                     = "${var.project_id}-input"
  location                 = var.region
  force_destroy            = true
  public_access_prevention = "enforced"
}

resource "google_storage_bucket" "processed_bucket" {
  name                     = "${var.project_id}-processed"
  location                 = var.region
  force_destroy            = true
  public_access_prevention = "enforced"
}

# 2. Dataset e Tabela do BigQuery
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "pipeline_data"
  location   = var.region
}

resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "processed_records"

  schema = <<EOF
[
  {"name": "id", "type": "STRING", "mode": "REQUIRED"},
  {"name": "timestamp", "type": "TIMESTAMP", "mode": "REQUIRED"},
  {"name": "payload", "type": "STRING", "mode": "NULLABLE"},
  {"name": "status", "type": "STRING", "mode": "NULLABLE"}
]
EOF
}

# 3. Service Account e IAM (Princípio do Menor Privilégio)
resource "google_service_account" "pipeline_sa" {
  account_id   = "sa-pipeline-runner"
  display_name = "Service Account do Pipeline Event-Driven"
}

resource "google_project_iam_member" "storage_role" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

resource "google_project_iam_member" "bigquery_role" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# 4. Trigger do Eventarc
resource "google_eventarc_trigger" "storage_trigger" {
  name     = "trigger-storage-input"
  location = var.region

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.input_bucket.name
  }

  destination {
    cloud_run_service {
      service = "pipeline-processor"
      region  = var.region
    }
  }

  service_account = google_service_account.pipeline_sa.email
}