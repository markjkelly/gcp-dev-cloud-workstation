# Default to local backend for ease of first-time setup and immediate use.
terraform {
  backend "local" {}
}

# To migrate to a GCS remote backend for durability and collaboration:
# 1. Create a GCS bucket (e.g. gcloud storage buckets create gs://YOUR_PROJECT_ID-tfstate)
# 2. Uncomment the block below and replace the bucket name.
# 3. Run `terraform init -migrate-state`
#
# terraform {
#   backend "gcs" {
#     bucket = "YOUR_PROJECT_ID-tfstate"
#     prefix = "terraform/state/cloud-workstation"
#   }
# }
