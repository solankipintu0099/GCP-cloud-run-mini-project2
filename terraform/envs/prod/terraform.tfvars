project_id        = "REPLACE-WITH-PROD-PROJECT-ID"
region            = "asia-south1"
environment       = "prod"
github_repository = "solankipintu0099/GCP-cloud-run-mini-project2"
github_ref        = "refs/heads/main"
service_name      = "gcp-cloudrun-demo"

# Prod: protected from destroy, private by default, one instance always warm.
deletion_protection = true
allow_public_access = false # set true if this is a public website
min_instance_count  = 1     # billed even when idle; set 0 to save money
max_instance_count  = 5

# Network: each environment gets its own non-overlapping range.
subnet_cidr = "10.30.0.0/24"
enable_nat  = false # true = fixed outbound IP via Cloud NAT (billed)

# demo_secret never goes in this file. Pass it with: export TF_VAR_demo_secret='...'
