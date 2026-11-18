# State lives in a GCS bucket inside this environment's own project.
# setup.sh creates the bucket if it doesn't exist.
terraform {
  backend "gcs" {
    bucket = "silken-apex-472910-m8-tfstate"
    prefix = "cloudrun-demo/dev"
  }
}
