# This file is the same in every envs/<name>/ folder.
# What differs between environments lives in terraform.tfvars and backend.tf.

module "network" {
  source = "../../modules/network"

  project_id  = var.project_id
  region      = var.region
  subnet_cidr = var.subnet_cidr
  enable_nat  = var.enable_nat
}

module "app" {
  source = "../../modules/cloudrun-app"

  project_id        = var.project_id
  region            = var.region
  environment       = var.environment
  github_repository = var.github_repository
  github_ref        = var.github_ref
  service_name      = var.service_name
  demo_secret       = var.demo_secret

  deletion_protection = var.deletion_protection
  allow_public_access = var.allow_public_access
  min_instance_count  = var.min_instance_count
  max_instance_count  = var.max_instance_count

  vpc_network    = module.network.network_name
  vpc_subnetwork = module.network.subnetwork_name
  vpc_egress     = module.network.cloud_run_egress
}
