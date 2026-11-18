variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
  default     = "asia-south1"
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_ref" {
  description = "Allowed GitHub ref, for example refs/heads/main"
  type        = string
  default     = "refs/heads/main"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "gcp-cloudrun-demo"
}

variable "image" {
  description = "Initial container image for Cloud Run; later images are deployed by GitHub Actions"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "demo_secret" {
  description = "Value stored in Secret Manager as the demo secret"
  type        = string
  sensitive   = true
  ephemeral   = true
}
