# State lives in a GCS bucket inside this environment's own project.
# setup.sh creates the bucket if it doesn't exist.
terraform {
  backend "gcs" {
    bucket = "REPLACE-WITH-STAGING-PROJECT-ID-tfstate"
    prefix = "cloudrun-demo/staging"
  }
}
