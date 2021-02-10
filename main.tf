provider "google" {
  project = "var.project"
  region  = "var.region"
  zone    = "var.zone"
}

# Enable services in newly created GCP Project.
resource "google_project_service" "gcp_services" {
  count   = length(var.gcp_service_list)
  project = var.project
  service = var.gcp_service_list[count.index]

  disable_dependent_services = true
}

resource "google_service_account" "sa" {
  account_id   = "my-service-account"
  display_name = "A service account that only Jane can use"
}

resource "google_service_account_iam_binding" "role-binding" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.securityAdmin"
  members = ["serviceAccount:${var.project}@appspot.gserviceaccount.com]"]
  //depends_on = [google_service_account.chd_creator]
}

resource "google_service_account_iam_binding" "role-binding-storage" {
  service_account_id = google_service_account.sa.name
  role               = "roles/storage.admin"
  members = ["serviceAccount:${var.project}@appspot.gserviceaccount.com]"]
  //depends_on = [google_service_account.chd_creator]
}
resource "google_service_account_iam_binding" "role-binding-cluster" {
  service_account_id = google_service_account.sa.name
  role               = "roles/container.clusterAdmin"
  members = ["serviceAccount:${var.project}@appspot.gserviceaccount.com]"]
  //depends_on = [google_service_account.chd_creator]
}
resource "google_service_account_iam_binding" "role-binding-network-admin" {
  service_account_id = google_service_account.sa.name
  role               = "roles/compute.networkAdmin"
  members = ["serviceAccount:${var.project}@appspot.gserviceaccount.com]"]
  //depends_on = [google_service_account.chd_creator]
}
resource "google_service_account_iam_binding" "role-binding-security-admin" {
  service_account_id = google_service_account.sa.name
  role               = "roles/compute.securityAdmin"
  members = ["serviceAccount:${var.project}@appspot.gserviceaccount.com]"]
  //depends_on = [google_service_account.chd_creator]
}
//["roles/iam.securityAdmin","roles/storage.admin","roles/container.clusterAdmin","roles/compute.networkAdmin","roles/compute.securityAdmin"]

resource "google_pubsub_topic" "mcp-topic" {
  project = "${var.project}"
  name = "topic-${var.project}"
}

resource "google_logging_project_sink" "mcp-sink" {
  project = "${var.project}"
  name = "logging-sink-pubsub-${var.project}"
  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.mcp-topic.name}"
  //filter = "logName:\"/logs/cloudaudit.googleapis.com\" OR resource.type=gce_instance"

  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_binding" "mcp-log-writer" {
  project = "${google_logging_project_sink.mcp-sink.project}"
  topic = "${google_pubsub_topic.mcp-topic.name}"
  role = "roles/pubsub.publisher"

  members = ["serviceAccount:${var.project}@appspot.gserviceaccount.com]"]
}

# resource "google_cloudfunctions_function" "main" {
#   project               = var.project
#   region                = var.region
#   name                  = var.name
#   description           = var.description
#   runtime               = var.runtime
#   available_memory_mb   = var.available_memory_mb
#   source_archive_bucket = var.source_archive_bucket
#   source_archive_object = var.source_archive_object
#   trigger_http          = var.trigger_http
#   timeout               = var.timeout
#   entry_point           = var.entry_point
#   service_account_email = google_service_account.main.email
#   environment_variables = var.environment_variables
# }

resource "random_id" "source" {
  keepers = {}
  byte_length = 4
}

resource "google_storage_bucket" "source" {
  project   = var.project
  name      = random_id.source.hex
}

data "archive_file" "source" {
  type        = "zip"
  output_path = ".pkg/source.zip"
  source {
    content  = "${file("/Users/pavithranagaraj/Documents/terraform/sh_to_tf/main.py")}"
    filename = "main.py"
  }
}


resource "google_storage_bucket_object" "source" {
  name   = "source.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.source.output_path
  depends_on = [data.archive_file.source]
}

resource "google_cloudfunctions_function" "GET__random_word" {
  project                   = var.project
  name                      = "GET__random_word"
  entry_point               = "random_word"
  runtime                   = "python37"
  available_memory_mb       = 128
  timeout                   = 61
  trigger_http              = true
  source_archive_bucket     = google_storage_bucket.source.name
  source_archive_object     = google_storage_bucket_object.source.name
}
