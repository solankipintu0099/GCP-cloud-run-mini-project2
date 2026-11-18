output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "artifact_registry" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}"
}

output "cloud_run_url" {
  value = google_cloud_run_v2_service.app.uri
}

output "github_service_account" {
  value = google_service_account.github_deploy.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}
