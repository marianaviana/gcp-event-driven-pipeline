variable "project_id" {
  description = "ID do Projeto no GCP"
  type        = string
  default     = "gcp-event-driven-pipeline"
}

variable "region" {
  description = "Região dos recursos"
  type        = string
  default     = "us-central1"
}