# =============================================================================
# Enable Required GCP APIs
# =============================================================================

resource "google_project_service" "workstations" {
  service                    = "workstations.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "artifactregistry" {
  service                    = "artifactregistry.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "cloudscheduler" {
  service                    = "cloudscheduler.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

# =============================================================================
# Network Setup
# =============================================================================

resource "google_compute_network" "workstations_vpc" {
  name                    = "workstations-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "workstations_subnet" {
  name          = "workstations-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.workstations_vpc.id
}

resource "google_compute_router" "workstations_router" {
  name    = "workstations-router"
  network = google_compute_network.workstations_vpc.id
}

resource "google_compute_router_nat" "workstations_nat" {
  name                               = "workstations-nat"
  router                             = google_compute_router.workstations_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# =============================================================================
# Artifact Registry for Workstation Docker Images
# =============================================================================

resource "google_artifact_registry_repository" "workstation_images" {
  repository_id = "workstation-images"
  format        = "DOCKER"
  description   = "Repository for custom Cloud Workstation Docker images"

  cleanup_policies {
    id     = "keep-5-most-recent-tagged"
    action = "KEEP"
    most_recent_versions {
      keep_count = 5
    }
  }

  cleanup_policies {
    id     = "delete-untagged-30d"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "2592000s" # 30 days
    }
  }

  depends_on = [google_project_service.artifactregistry]
}

# =============================================================================
# Workstations Cluster
# =============================================================================

resource "google_workstations_workstation_cluster" "main" {
  provider               = google-beta
  workstation_cluster_id = var.cluster_id
  location               = var.region

  network    = google_compute_network.workstations_vpc.id
  subnetwork = google_compute_subnetwork.workstations_subnet.id

  labels = {
    environment = "common"
    application = "cloud-workstation"
    cost_center = "cc-1001"
    team        = "platform-eng"
  }

  depends_on = [google_project_service.workstations]
}

# =============================================================================
# VM Service Account & Permissions
# =============================================================================

resource "google_service_account" "workstation" {
  account_id   = "workstation-sa"
  display_name = "Workstation VM Service Account"
}

# Grant the Workstation VM Service Account read access to the Artifact Registry repository
resource "google_artifact_registry_repository_iam_member" "workstation_sa_ar_reader" {
  repository = google_artifact_registry_repository.workstation_images.name
  location   = google_artifact_registry_repository.workstation_images.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.workstation.email}"
}

# =============================================================================
# Workstation Configuration
# =============================================================================

resource "google_workstations_workstation_config" "main" {
  provider               = google-beta
  workstation_config_id  = var.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.main.workstation_cluster_id
  location               = var.region

  host {
    gce_instance {
      machine_type                = var.machine_type
      boot_disk_size_gb           = 200
      disable_public_ip_addresses = true
      service_account             = google_service_account.workstation.email
      service_account_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]

      shielded_instance_config {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
      }
    }
  }

  container {
    image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.workstation_images.repository_id}/dev-workstation:latest"
  }

  persistent_directories {
    mount_path = "/home"
    gce_pd {
      size_gb        = var.disk_size_gb
      fs_type        = "ext4"
      disk_type      = "pd-balanced"
      reclaim_policy = "RETAIN"
    }
  }

  idle_timeout    = "7200s"  # 2 hours idle -> stop
  running_timeout = "43200s" # 12 hours max runtime
}

# =============================================================================
# Workstation Instance
# =============================================================================

resource "google_workstations_workstation" "main" {
  provider               = google-beta
  workstation_id         = var.workstation_id
  workstation_config_id  = google_workstations_workstation_config.main.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.main.workstation_cluster_id
  location               = var.region

  labels = {
    environment = "common"
    application = "cloud-workstation"
    cost_center = "cc-1001"
    team        = "platform-eng"
  }
}

# Grant user workstations.user permissions on the config if email is provided
resource "google_workstations_workstation_config_iam_member" "user" {
  count                  = var.user_email != "" ? 1 : 0
  provider               = google-beta
  location               = var.region
  workstation_cluster_id = google_workstations_workstation_cluster.main.workstation_cluster_id
  workstation_config_id  = google_workstations_workstation_config.main.workstation_config_id
  role                   = "roles/workstations.user"
  member                 = "user:${var.user_email}"
}

# =============================================================================
# Backup & Snapshot Policy
# =============================================================================

resource "google_compute_resource_policy" "workstation_home_daily_snapshot" {
  name   = "workstation-home-daily-snapshots"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = {
        environment         = "common"
        application         = "cloud-workstation"
        cost_center         = "cc-1001"
        team                = "platform-eng"
        data_classification = "confidential"
      }
      storage_locations = [var.region]
    }
  }
}

# Workstations manages persistent disks automatically.
# We attach the resource policy to the disks using gcloud CLI at apply time.
resource "null_resource" "attach_workstation_snapshot_policy" {
  triggers = {
    policy_id      = google_compute_resource_policy.workstation_home_daily_snapshot.id
    workstation_id = google_workstations_workstation.main.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      PROJECT="${var.project_id}"
      POLICY_NAME="${google_compute_resource_policy.workstation_home_daily_snapshot.name}"
      REGION="${var.region}"

      echo "Attaching snapshot policy $POLICY_NAME to workstation disks..."

      # Wait for the workstation disk to be created by starting/stopping the VM
      # or checking if it exists. Workstation creation pre-creates the disk.
      gcloud compute disks list \
        --project="$PROJECT" \
        --filter="name:workstations AND zone:$REGION-*" \
        --format="csv[no-heading](name,zone.scope(zones))" \
        --quiet \
      | while IFS=, read -r DISK ZONE; do
          [ -z "$ZONE" ] && continue
          echo "  -> Attaching policy to disk: $DISK ($ZONE)"
          gcloud compute disks add-resource-policies "$DISK" \
            --zone="$ZONE" \
            --resource-policies="$POLICY_NAME" \
            --project="$PROJECT" \
            --quiet 2>&1 || true
        done

      echo "Disk snapshot policy attachment completed."
    EOT
  }
}
