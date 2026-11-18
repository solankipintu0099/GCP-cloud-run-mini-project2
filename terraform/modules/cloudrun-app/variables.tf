variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
  default     = "asia-south1"
}

variable "environment" {
  description = "Environment name; must match the GitHub Environment that deploys it"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
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

variable "deletion_protection" {
  description = "Block terraform destroy from deleting the Cloud Run service"
  type        = bool
  default     = true
}

variable "allow_public_access" {
  description = "Let anyone on the internet call the service (grants roles/run.invoker to allUsers)"
  type        = bool
  default     = false
}

variable "min_instance_count" {
  description = "Instances kept warm; anything above 0 is billed even when idle"
  type        = number
  default     = 0
}

variable "max_instance_count" {
  description = "Upper bound on Cloud Run instances"
  type        = number
  default     = 2
}

variable "vpc_network" {
  description = "VPC network name for Direct VPC egress; null keeps the service off any VPC"
  type        = string
  default     = null
}

variable "vpc_subnetwork" {
  description = "Subnet name Cloud Run instances take private IPs from"
  type        = string
  default     = null
}

variable "vpc_egress" {
  description = "PRIVATE_RANGES_ONLY sends only private-IP traffic through the VPC; ALL_TRAFFIC sends everything (needed for Cloud NAT)"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"

  validation {
    condition     = contains(["PRIVATE_RANGES_ONLY", "ALL_TRAFFIC"], var.vpc_egress)
    error_message = "vpc_egress must be PRIVATE_RANGES_ONLY or ALL_TRAFFIC."
  }
}
