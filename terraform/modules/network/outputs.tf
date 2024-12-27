output "vpc_id" {
    value = google_compute_network.vpc.id
}
output "public_subnets_ids" {
    value = google_compute_subnetwork.public.*.id
}
output "private_subnets_ids" {
    value = google_compute_subnetwork.private.*.id
}