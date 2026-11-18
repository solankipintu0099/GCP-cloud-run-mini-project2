# GCP Cloud Run Mini Project

A minimal Cloud Run deployment project demonstrating Terraform, Docker, Secret Manager, Cloud Run, and GitHub Actions OIDC authentication, with separate dev, staging and prod environments.

## Architecture

GitHub Actions → OIDC Workload Identity Federation → GCP service account → Artifact Registry → Cloud Run

Each environment (dev, staging, prod) is fully isolated:

- its own GCP project
- its own Terraform state, in a GCS bucket in that project
- its own GitHub Environment with its own secrets

A mistake in dev can't touch prod: the prod project only accepts GitHub tokens from a job running in the `prod` GitHub Environment.

## Terraform layout

```
terraform/
  modules/
    network/              # VPC, Cloud Run subnet, optional Cloud NAT
    cloudrun-app/         # Cloud Run, Secret Manager, Artifact Registry, IAM, GitHub OIDC
  envs/
    dev/                  # one folder per environment
    staging/
    prod/
```

Inside each `envs/<name>/` folder, `main.tf`, `variables.tf`, `outputs.tf` and `providers.tf` are the same in every environment. Only two files differ:

- `terraform.tfvars`: project ID and per-environment settings (deletion protection, public access, instance counts)
- `backend.tf`: the state bucket and prefix

| Setting | dev | staging | prod |
|---|---|---|---|
| `deletion_protection` | false | true | true |
| `allow_public_access` | true | true | false |
| `min_instance_count` | 0 | 0 | 1 |
| `max_instance_count` | 2 | 3 | 5 |
| `subnet_cidr` | 10.10.0.0/24 | 10.20.0.0/24 | 10.30.0.0/24 |
| `enable_nat` | false | false | false |

## Network

Each environment has its own VPC (`cloudrun-demo-vpc`) with one subnet for Cloud Run. Subnet ranges don't overlap, so the environments can be connected later (VPC peering, VPN) without renumbering.

Cloud Run joins the subnet through **Direct VPC egress**:

- `enable_nat = false` (default): egress is `PRIVATE_RANGES_ONLY`. Traffic to private IPs (for example, Cloud SQL or Redis added later) goes through the VPC; internet traffic goes out directly. No extra cost.
- `enable_nat = true`: egress is `ALL_TRAFFIC`, and internet traffic leaves through Cloud NAT from a fixed IP (the `nat_ip` output), for APIs that allowlist IP addresses. Cloud NAT and the static IP are billed, and Google notes cold starts can take 30 s or more with Cloud NAT.

There are no firewall rules yet: a custom VPC denies all incoming traffic by default. Add rules when a private resource needs to accept connections from the Cloud Run subnet.

Enabling the Compute Engine API creates a `default` network in new projects, with firewall rules that allow SSH and RDP from anywhere. Nothing here uses it, so you can delete it:

```bash
gcloud compute firewall-rules list --project PROJECT_ID --filter="network=default" --format="value(name)" \
  | xargs -r gcloud compute firewall-rules delete --project PROJECT_ID --quiet
gcloud compute networks delete default --project PROJECT_ID --quiet
```

## Prerequisites

- One GCP project per environment, each with billing enabled
- `gcloud` CLI
- Terraform 1.11 or newer (needed for the write-only secret value)
- Docker
- A GitHub repository

## Create an environment

Log in once:

```bash
gcloud auth login
gcloud auth application-default login
```

For staging or prod, first replace the `REPLACE-WITH-...` placeholders in that environment's `terraform.tfvars` and `backend.tf` with the real project ID.

Then run:

```bash
./setup.sh dev        # or staging / prod
```

The script enables the required APIs, creates the state bucket (versioned, private) if needed, asks for the demo secret value, and runs `terraform init`, `plan` and, after you confirm, `apply`.

The demo secret is sent to Secret Manager but never written to Terraform state or to git. To run Terraform by hand instead:

```bash
export TF_VAR_demo_secret='choose-a-demo-value'
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

Commit each environment's `.terraform.lock.hcl` so everyone uses the same provider version.

After the first deploy, GitHub Actions owns the container image. Terraform ignores image changes, so running `terraform apply` again won't roll the service back to the placeholder image.

## GitHub Actions configuration

In the repository, go to **Settings → Environments** and create three environments named exactly `dev`, `staging` and `prod`. On `prod`, turn on **Required reviewers** so every prod deploy needs approval.

In each environment, add these **secrets**, using that environment's `terraform output`:

- `GCP_PROJECT_ID`: the `project_id` output
- `GCP_SERVICE_ACCOUNT`: the `github_service_account` output
- `GCP_WORKLOAD_IDENTITY_PROVIDER`: the `workload_identity_provider` output

Add these repository **variables** (Settings → Secrets and variables → Actions → Variables). They're shared by all environments:

- `GCP_REGION` = `asia-south1`
- `GCP_ARTIFACT_REPOSITORY` = `cloud-run-demo`
- `GCP_SERVICE_NAME` = `gcp-cloudrun-demo`

## Run locally

```bash
cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
pytest -q
python main.py
```

Open `http://localhost:8080/health`.

## Deploy

- **dev**: push to `main`.
- **staging / prod**: go to **Actions → Deploy to Cloud Run → Run workflow**, choose `main` and the environment. Prod waits for a reviewer's approval.

Each run:

1. Runs the tests. If they fail, nothing is deployed.
2. Exchanges a GitHub OIDC token for temporary GCP credentials for that environment's project.
3. Builds the Docker image.
4. Pushes it to that project's Artifact Registry.
5. Deploys it to Cloud Run.

## Important files

- `app/`: Flask application and Docker image
- `terraform/modules/network/`: VPC, subnet and optional Cloud NAT
- `terraform/modules/cloudrun-app/`: Cloud Run and everything it needs, defined once
- `terraform/envs/`: one folder per environment (`setup.sh` creates the state bucket)
- `setup.sh`: creates an environment end to end
- `.github/workflows/deploy.yml`: keyless CI/CD workflow

## Security notes

- Public access is controlled only by `allow_public_access` in Terraform. The deploy service account has `roles/run.developer`, which can deploy but can't change who may call the service.
- Prod is private by default. Set `allow_public_access = true` in `envs/prod/terraform.tfvars` if it's a public website.
