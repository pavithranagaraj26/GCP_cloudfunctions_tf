project_name = "ia-devops" # Update: Desired project name.
labels = {
  "environment" = "test"
  "team"        = "devops"
}
gcp_service_list = [
    "cloudresourcemanager.googleapis.com",
    "pubsub.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "secretmanager.googleapis.com"
]