output "workstation_url" {
  description = "The direct web URL to connect to the workstation."
  value       = "https://${google_workstations_workstation.main.host}"
}

output "artifact_registry_repo" {
  description = "The URI of the Artifact Registry repository."
  value       = "${google_artifact_registry_repository.workstation_images.location}-docker.pkg.dev/${google_artifact_registry_repository.workstation_images.project}/${google_artifact_registry_repository.workstation_images.repository_id}"
}

output "vpc_network_name" {
  description = "The name of the VPC network created for the workstation."
  value       = google_compute_network.workstations_vpc.name
}

output "workstation_service_account_email" {
  description = "The service account email assigned to the workstation VM."
  value       = google_service_account.workstation.email
}
