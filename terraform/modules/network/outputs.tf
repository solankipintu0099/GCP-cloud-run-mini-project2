output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.cloudrun.name
}

output "nat_ip" {
  description = "Fixed outbound IP, or null when NAT is disabled"
  value       = var.enable_nat ? google_compute_address.nat[0].address : null
}

output "cloud_run_egress" {
  description = "Egress mode Cloud Run must use with this network"
  # Internet traffic only reaches Cloud NAT if all traffic goes through the VPC.
  value = var.enable_nat ? "ALL_TRAFFIC" : "PRIVATE_RANGES_ONLY"
}
