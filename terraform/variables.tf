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
  description = "Container image URI deployed to Cloud Run"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}
