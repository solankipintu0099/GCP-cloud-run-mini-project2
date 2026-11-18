project_id        = "silken-apex-472910-m8"
region            = "asia-south1"
environment       = "dev"
github_repository = "solankipintu0099/GCP-cloud-run-mini-project2"
github_ref        = "refs/heads/main"
service_name      = "gcp-cloudrun-demo"

# Dev: cheap and easy to tear down.
deletion_protection = false
allow_public_access = true
min_instance_count  = 0
max_instance_count  = 2

# Network: each environment gets its own non-overlapping range.
subnet_cidr = "10.10.0.0/24"
enable_nat  = false # true = fixed outbound IP via Cloud NAT (billed)

# demo_secret never goes in this file. Pass it with: export TF_VAR_demo_secret='...'
