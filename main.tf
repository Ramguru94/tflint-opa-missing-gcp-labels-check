resource "google_compute_disk" "test_disk_with_labels" {
  name = "test-disk-with-labels"
  zone = "us-central1-a"
  size = 50
  type = "pd-standard"
  labels = {
    Environment = "development"
    Owner       = "team"
  }
}

resource "google_compute_disk" "test_disk_missing_labels" {
  name = "test-disk-missing-labels"
  zone = "us-central1-b"
  size = 100
  type = "pd-ssd"
}

resource "google_compute_disk" "test_disk_empty_labels" {
  name   = "test-disk-empty-labels"
  zone   = "us-central1-c"
  size   = 200
  type   = "pd-standard"
  labels = {}
}

resource "google_compute_instance" "test_instance_missing_labels" {
  name         = "test-instance-missing-labels"
  machine_type = "n1-standard-1"
  zone         = "us-central1-b"
  tags         = ["web"]

  boot_disk {
    initialize_params {
      image = "your-image"
    }
  }

  network_interface {
    network = "your-network"
  }
}

resource "google_compute_image" "test_image_with_labels" {
  name   = "test-image-with-labels"
  family = "debian-9"
  labels = {
    Environment = "production"
    Owner       = "team"
  }
}

resource "google_compute_image" "test_image_missing_labels" {
  name   = "test-image-missing-labels"
  family = "debian-10"
}

resource "google_compute_image" "test_image_empty_labels" {
  name   = "test-image-empty-labels"
  family = "debian-11"
  labels = {}
}

resource "google_compute_address" "test_address_with_labels" {
  name   = "test-address-with-labels"
  region = "us-central1"
  labels = {
    Environment = "staging"
    Owner       = "team"
  }
}

resource "google_compute_address" "test_address_missing_labels" {
  name   = "test-address-missing-labels"
  region = "us-central1"
}

resource "google_compute_address" "test_address_empty_labels" {
  name   = "test-address-empty-labels"
  region = "us-central1"
  labels = {}
}

resource "google_pubsub_topic" "test_pubsub_topic_with_labels" {
  name = "test-pubsub-topic-with-labels"
  labels = {
    Environment = "development"
    Owner       = "team"
  }
}

resource "google_pubsub_topic" "test_pubsub_topic_missing_labels" {
  name = "test-pubsub-topic-missing-labels"
}

resource "google_pubsub_topic" "test_pubsub_topic_empty_labels" {
  name   = "test-pubsub-topic-empty-labels"
  labels = {}
}

resource "google_alloydb_user" "test_alloydb_user_missing_labels" {
  name      = "test-alloydb-user-missing-labels"
  user_id   = "your-user-id"
  user_type = "ALLOYDB_BUILT_IN"
  cluster   = "your-cluster"
}

resource "google_apikeys_key" "test_apikeys_key_with_labels" {
  name = "test-apikeys-key-with-labels"
}

resource "google_apikeys_key" "test_apikeys_key_missing_labels" {
  name = "test-apikeys-key-missing-labels"
}

resource "google_apikeys_key" "test_apikeys_key_empty_labels" {
  name = "test-apikeys-key-empty-labels"
}

resource "google_apphub_service" "test_apphub_service_missing_labels" {
  name               = "test-apphub-service-missing-labels"
  service_id         = "your-service-id"
  application_id     = "your-application-id"
  location           = "your-location"
  discovered_service = "your-discovered-service"
}

resource "google_apphub_service" "test_apphub_service_empty_labels" {
  name               = "test-apphub-service-empty-labels"
  service_id         = "your-service-id"
  application_id     = "your-application-id"
  location           = "your-location"
  discovered_service = "your-discovered-service"
}

resource "google_cloud_run_service" "test_cloud_run_service_with_labels" {
  name     = "test-cloud-run-service-with-labels"
  location = "us-central1"
}

resource "google_cloud_run_service" "test_cloud_run_service_missing_labels" {
  name     = "test-cloud-run-service-missing-labels"
  location = "us-central1"
}

resource "google_cloud_run_service" "test_cloud_run_service_empty_labels" {
  name     = "test-cloud-run-service-empty-labels"
  location = "us-central1"
}

resource "google_compute_instance_group" "test_instance_group_with_labels" {
  name = "test-instance-group-with-labels"
  zone = "us-central1-a"
  instances = [
    google_compute_instance.test_instance_with_labels.self_link
  ]
}

resource "google_compute_instance_group" "test_instance_group_missing_labels" {
  name = "test-instance-group-missing-labels"
  zone = "us-central1-b"
  instances = [
    google_compute_instance.test_instance_missing_labels.self_link
  ]
}

resource "google_compute_instance_group" "test_instance_group_empty_labels" {
  name = "test-instance-group-empty-labels"
  zone = "us-central1-c"
  instances = [
    google_compute_instance.test_instance_empty_labels.self_link
  ]
}
