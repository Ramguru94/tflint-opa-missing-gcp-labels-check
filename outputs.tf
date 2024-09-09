# Define any outputs you need here
# Example:
output "disk_labels" {
  value = google_compute_disk.test_disk_with_labels.labels
  description = "value of labels for the disk"
}
