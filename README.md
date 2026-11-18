# GCP Cloud Run Mini Project

A minimal Cloud Run deployment project demonstrating Terraform, Docker, Secret Manager, Cloud Run, and GitHub Actions OIDC authentication.

## Architecture

GitHub Actions → OIDC Workload Identity Federation → GCP service account → Artifact Registry → Cloud Run

## Prerequisites

- A GCP project with billing enabled
- `gcloud` CLI
- Terraform 1.5 or newer
- Docker
- A GitHub repository

## GCP and local setup

```bash
gcloud auth application-default login
gcloud auth login
gcloud services enable cloudresourcemanager.googleapis.com iam.googleapis.com
```

Copy the example Terraform variables:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars`, then run:

```bash
terraform init
terraform plan
terraform apply
terraform output
```

## GitHub Actions configuration

Create these repository **secrets**:

- `GCP_PROJECT_ID`
- `GCP_SERVICE_ACCOUNT`
- `GCP_WORKLOAD_IDENTITY_PROVIDER`

Create these repository **variables**:

- `GCP_REGION` = `asia-south1`
- `GCP_ARTIFACT_REPOSITORY` = `cloud-run-demo`
- `GCP_SERVICE_NAME` = `gcp-cloudrun-demo`

The Terraform outputs provide the service account and workload identity provider values.

## Run locally

```bash
cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py
```

Open `http://localhost:8080/health`.

## Deploy

Push to `main`. GitHub Actions will:

1. Exchange a GitHub OIDC token for temporary GCP credentials.
2. Build the Docker image.
3. Push it to Artifact Registry.
4. Deploy it to Cloud Run.

## Important files

- `app/` — Flask application and Docker image
- `terraform/` — GCP infrastructure
- `.github/workflows/deploy.yml` — keyless CI/CD workflow

## Security note

The demo Cloud Run service is intentionally public. For a real service, remove `allUsers` and configure controlled invoker access.
