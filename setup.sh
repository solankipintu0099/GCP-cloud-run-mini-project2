#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${1:-}"
GITHUB_REPOSITORY="${2:-}"
REGION="${3:-asia-south1}"

if [[ -z "$PROJECT_ID" || -z "$GITHUB_REPOSITORY" ]]; then
  echo "Usage: ./setup.sh PROJECT_ID GITHUB_OWNER/GITHUB_REPOSITORY [REGION]"
  exit 1
fi

gcloud config set project "$PROJECT_ID"

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  run.googleapis.com \
  secretmanager.googleapis.com \
  sts.googleapis.com

cat > terraform/terraform.tfvars <<EOF
project_id        = "$PROJECT_ID"
region            = "$REGION"
github_repository = "$GITHUB_REPOSITORY"
github_ref        = "refs/heads/main"
service_name      = "gcp-cloudrun-demo"
EOF

if [[ -z "${TF_VAR_demo_secret:-}" ]]; then
  read -r -s -p "Demo secret value (stored in Secret Manager): " TF_VAR_demo_secret
  echo
  export TF_VAR_demo_secret
fi

cd terraform
terraform init
terraform plan

echo
read -r -p "Apply Terraform infrastructure? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  terraform apply
  echo
  terraform output
fi
