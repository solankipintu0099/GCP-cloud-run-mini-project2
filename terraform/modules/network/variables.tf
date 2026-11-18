variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the subnet and Cloud NAT"
  type        = string
}

variable "subnet_cidr" {
  description = "Private IP range for the Cloud Run subnet; must not overlap other environments"
  type        = string

  validation {
    # Cloud Run Direct VPC egress needs a /26 or larger subnet.
    condition     = can(cidrhost(var.subnet_cidr, 0)) && can(regex("/([89]|1[0-9]|2[0-6])$", var.subnet_cidr))
    error_message = "subnet_cidr must be a valid IPv4 range between /8 and /26, e.g. 10.10.0.0/24."
  }
}

variable "enable_nat" {
  description = "Send Cloud Run's internet traffic through Cloud NAT with a fixed outbound IP (billed)"
  type        = bool
  default     = false
}
