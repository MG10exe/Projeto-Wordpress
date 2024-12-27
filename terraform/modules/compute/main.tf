resource "google_compute_instance" "web" {
  count         = var.compute_settings.count
  name          = "tutorial-web-${count.index}"
  machine_type  = var.compute_settings.machine_type
  zone          = "${var.region}-a"
  boot_disk {
    initialize_params {
        image = "projects/${var.compute_settings.source_image_project}/global/images/family/${var.compute_settings.source_image_family}"
    }
  }
  network_interface {
    subnetwork = var.public_subnets_ids[0]
    access_config {}
  }

  metadata = {
    ssh-keys = "matheusgandrade:${data.google_secret_manager_secret_version.chave_publica.secret_data}"
    }
}

#resource "google_compute_address" "static" {
#  count = var.compute_settings.count
#  name = "ip-estatico-${count.index}"
#  region = var.region
#}

resource "google_compute_instance_network_interface" "nic" {
  count = var.compute_settings.count
 instance = google_compute_instance.web[count.index].id
  network_interface_id = 0
  network = var.vpc_id
  subnetwork = var.public_subnets_ids[0]
  alias_ip_range {
    ip_cidr_range         = "10.128.0.0/24"
    subnetwork_range_name = "ip-range-padrao"
  }
}

resource "google_compute_network_interface_attachment" "attachment" {
  count = var.compute_settings.count
  instance         = google_compute_instance.web[count.index].id
  network_interface = 0
  ip_address = google_compute_address.static[count.index].address
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["${var.my_ip}/32"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_db" {
  name    = "allow-db"
  network = var.vpc_id
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_ranges = [var.vpc_cidr_block]
}