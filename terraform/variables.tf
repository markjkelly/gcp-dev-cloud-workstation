variable "project_id" {
  description = "The GCP Project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources to."
  type        = string
  default     = "us-central1"
}

variable "cluster_id" {
  description = "The ID of the Cloud Workstation Cluster."
  type        = string
  default     = "main-cluster"
}

variable "workstation_config_id" {
  description = "The ID of the Cloud Workstation Configuration."
  type        = string
  default     = "gcp-dev-cloud-workstation-config"
}

variable "workstation_id" {
  description = "The ID of the Cloud Workstation instance."
  type        = string
  default     = "gcp-dev-cloud-workstation"
}

variable "machine_type" {
  description = "The GCE machine type for the workstation VM."
  type        = string
  default     = "n2-standard-8"
}

variable "disk_size_gb" {
  description = "The persistent HOME disk size in GB."
  type        = number
  default     = 200
}

variable "user_email" {
  description = "The email address of the user to grant access to this workstation."
  type        = string
  default     = ""
}
