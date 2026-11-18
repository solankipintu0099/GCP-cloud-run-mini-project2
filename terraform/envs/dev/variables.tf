variable "project_id" {
  description = "GCP project ID for this environment"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
}

variable "environment" {
  description = "Environment name; must match this folder and the GitHub Environment"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_ref" {
  description = "Git ref allowed to deploy to this environment"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "demo_secret" {
  description = "Demo secret value; pass with TF_VAR_demo_secret, never in tfvars"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "deletion_protection" {
  description = "Block terraform destroy from deleting the Cloud Run service"
  type        = bool
}

variable "allow_public_access" {
  description = "Let anyone on the internet call the service"
  type        = bool
}

variable "min_instance_count" {
  description = "Instances kept warm; anything above 0 is billed even when idle"
  type        = number
}

variable "max_instance_count" {
  description = "Upper bound on Cloud Run instances"
  type        = number
}

variable "subnet_cidr" {
  description = "Private IP range for this environment's subnet; must not overlap other environments"
  type        = string
}

variable "enable_nat" {
  description = "Give Cloud Run a fixed outbound IP through Cloud NAT (billed)"
  type        = bool
}
