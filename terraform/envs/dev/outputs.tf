output "project_id" {
  value = module.app.project_id
}

output "region" {
  value = module.app.region
}

output "artifact_registry" {
  value = module.app.artifact_registry
}

output "cloud_run_url" {
  value = module.app.cloud_run_url
}

output "github_service_account" {
  value = module.app.github_service_account
}

output "workload_identity_provider" {
  value = module.app.workload_identity_provider
}

output "vpc_network" {
  value = module.network.network_name
}

output "nat_ip" {
  value = module.network.nat_ip
}
