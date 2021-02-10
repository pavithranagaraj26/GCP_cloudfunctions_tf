variable "project" {
  description = "The ID of the project in which to provision resources."
  default     = "ia-devops"
}

variable "region" {
  description = "The GCP region in which the resources will be provisioned."
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP region in which the resources will be provisioned."
  default     = "us-central1-a"
}


variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list
}

variable "name" {
  description = "The name of the cloud function to create"
  default = "firewall"
}

variable "description" {
  description = "The description of the cloud function"
  default     = "Created by Terraform"
}

variable "runtime" {
  description = "The runtime in which the function is running"
  default = "python37"
}

variable "available_memory_mb" {
  description = "Available memory (in MB) to the function."
  default     = 128
}

variable "source_archive_bucket" {
  description = "The GCS bucket containing the zip archive which contains the function"
}

variable "source_archive_object" {
  description = "The source archive object (file) in archive bucket"
}

variable "trigger_http" {
  description = "If function is triggered by HTTP, this boolean is set"
  default     = true
}

variable "timeout" {
  description = "Function execution timeout (in seconds)"
  default     = 60
}

variable "entry_point" {
  description = "Name of the function that will be executed when the Google Cloud Function is triggered"
  default = "run"
}

variable "environment_variables" {
  description = "A map of key/value environment variable pairs to assign to the function"
  default     = {}
}

variable "roles" {
  description = "A list of roles to apply to the service account"
  default     = []
}

variable "bucket" {
  description = "A list of roles to apply to the service account"
  default     = "GCS"
}