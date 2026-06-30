# =============================================================================
# Cloud Scheduler for Automatic Cost-Saving Shutdowns
# =============================================================================

resource "google_service_account" "workstation_scheduler" {
  account_id   = "workstation-scheduler"
  display_name = "Cloud Scheduler Workstation Controller"
}

# Grant Scheduler service account permission to call the workstations stop API
resource "google_workstations_workstation_iam_member" "scheduler_user" {
  provider               = google-beta
  location               = var.region
  workstation_cluster_id = google_workstations_workstation_cluster.main.workstation_cluster_id
  workstation_config_id  = google_workstations_workstation_config.main.workstation_config_id
  workstation_id         = google_workstations_workstation.main.workstation_id
  role                   = "roles/workstations.user"
  member                 = "serviceAccount:${google_service_account.workstation_scheduler.email}"
}

# Cloud Scheduler Job to stop the workstation daily at 8:00 PM Central time
resource "google_cloud_scheduler_job" "stop_workstation" {
  name      = "stop-workstation-8pm-central"
  region    = var.region
  schedule  = "0 20 * * *"
  time_zone = "America/Chicago" # Handles DST transitions automatically

  http_target {
    uri = join("/", [
      "https://workstations.googleapis.com/v1/projects/${var.project_id}",
      "locations/${var.region}",
      "workstationClusters/${google_workstations_workstation_cluster.main.workstation_cluster_id}",
      "workstationConfigs/${google_workstations_workstation_config.main.workstation_config_id}",
      "workstations/${google_workstations_workstation.main.workstation_id}:stop",
    ])
    http_method = "POST"

    oidc_token {
      service_account_email = google_service_account.workstation_scheduler.email
      audience              = "https://workstations.googleapis.com/"
    }
  }

  retry_config {
    retry_count          = 3
    min_backoff_duration = "5s"
    max_backoff_duration = "3600s"
    max_doublings        = 5
  }

  depends_on = [google_project_service.cloudscheduler]
}
