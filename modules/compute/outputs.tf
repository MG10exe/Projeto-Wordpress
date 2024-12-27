output "external_ips" {
  value = google_compute_address.static.*.address
}