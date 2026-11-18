#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
ENV_DIR="terraform/envs/$ENVIRONMENT"

if [[ -z "$ENVIRONMENT" || ! -f "$ENV_DIR/terraform.tfvars" ]]; then
  echo "Usage: ./setup.sh dev|staging|prod"
  exit 1
fi

# Reads a quoted value from an HCL file, e.g. project_id = "abc" -> abc
hcl_value() {
  sed -nE "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*\"([^\"]*)\".*/\1/p" "$2"
}

PROJECT_ID="$(hcl_value project_id "$ENV_DIR/terraform.tfvars")"
REGION="$(hcl_value region "$ENV_DIR/terraform.tfvars")"
STATE_BUCKET="$(hcl_value bucket "$ENV_DIR/backend.tf")"

if [[ -z "$PROJECT_ID" || -z "$STATE_BUCKET" || "$PROJECT_ID $STATE_BUCKET" == *REPLACE-WITH* ]]; then
  echo "Set the real project ID in $ENV_DIR/terraform.tfvars and $ENV_DIR/backend.tf first."
  exit 1
fi

echo "Environment: $ENVIRONMENT"
echo "Project:     $PROJECT_ID"
echo "Region:      $REGION"
echo "State:       gs://$STATE_BUCKET"
echo

gcloud services enable --project "$PROJECT_ID" \
  artifactregistry.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  run.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com \
  sts.googleapis.com

# Terraform can't create the bucket that holds its own state, so do it here.
if ! gcloud storage buckets describe "gs://$STATE_BUCKET" >/dev/null 2>&1; then
  gcloud storage buckets create "gs://$STATE_BUCKET" \
    --project "$PROJECT_ID" \
    --location "$REGION" \
    --uniform-bucket-level-access \
    --public-access-prevention
  gcloud storage buckets update "gs://$STATE_BUCKET" --versioning
fi

if [[ -z "${TF_VAR_demo_secret:-}" ]]; then
  read -r -s -p "Demo secret value for $ENVIRONMENT (stored in Secret Manager): " TF_VAR_demo_secret
  echo
  export TF_VAR_demo_secret
fi

terraform -chdir="$ENV_DIR" init
terraform -chdir="$ENV_DIR" plan

echo
read -r -p "Apply Terraform to $ENVIRONMENT ($PROJECT_ID)? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  terraform -chdir="$ENV_DIR" apply
  echo
  terraform -chdir="$ENV_DIR" output
fi
