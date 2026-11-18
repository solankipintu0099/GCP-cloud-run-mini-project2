project_id        = "REPLACE-WITH-STAGING-PROJECT-ID"
region            = "asia-south1"
environment       = "staging"
github_repository = "solankipintu0099/GCP-cloud-run-mini-project2"
github_ref        = "refs/heads/main"
service_name      = "gcp-cloudrun-demo"

# Staging: close to prod, but still scales to zero to save money.
deletion_protection = true
allow_public_access = true
min_instance_count  = 0
max_instance_count  = 3

# Network: each environment gets its own non-overlapping range.
subnet_cidr = "10.20.0.0/24"
enable_nat  = false # true = fixed outbound IP via Cloud NAT (billed)

# demo_secret never goes in this file. Pass it with: export TF_VAR_demo_secret='...'
