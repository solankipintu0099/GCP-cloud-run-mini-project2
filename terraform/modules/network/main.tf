resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "vpc" {
  name                    = "cloudrun-demo-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.compute]
}

# Cloud Run instances take private IPs from this subnet (Direct VPC egress),
# about two per instance, so it must be /26 or larger.
resource "google_compute_subnetwork" "cloudrun" {
  name                     = "cloudrun-demo-${var.region}"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

# No firewall rules are needed yet: a custom VPC already denies all incoming
# traffic by default. Add rules when a private resource (Cloud SQL, Redis, VM)
# needs to accept connections from the Cloud Run subnet.

# Optional fixed outbound IP, for calling APIs that allowlist IP addresses.
resource "google_compute_address" "nat" {
  count = var.enable_nat ? 1 : 0

  name   = "cloudrun-demo-nat-ip"
  region = var.region

  depends_on = [google_project_service.compute]
}

resource "google_compute_router" "nat" {
  count = var.enable_nat ? 1 : 0

  name    = "cloudrun-demo-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  count = var.enable_nat ? 1 : 0

  name                   = "cloudrun-demo-nat"
  router                 = google_compute_router.nat[0].name
  region                 = var.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.nat[0].self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.cloudrun.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
