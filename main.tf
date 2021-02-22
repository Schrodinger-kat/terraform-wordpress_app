provider "google" {
 credentials = file("SAKEY.json")
 project     = "gcp-training-01-303001"
 region = "us-east1"
}

#Networks
resource "google_compute_network" "pokenav" {
    name = var.vpc
    auto_create_subnetworks = false
}

#Subnets
resource "google_compute_subnetwork" "hoenn" {
    name = var.hoenn_sub
    region = var.hoenn
    ip_cidr_range   = var.hoenn_id_cidr
    network = google_compute_network.pokenav.self_link
    private_ip_google_access = true
    }

resource "google_compute_subnetwork" "kanto" {
    name = var.kanto_sub
    region = var.kanto
    ip_cidr_range   = var.kanto_id_cidr
    network = google_compute_network.pokenav.self_link
    private_ip_google_access = true
    }

#Firewall
resource "google_compute_firewall" "charizard" {
  name          = "allow-incoming-traffic"
  network       = google_compute_network.pokenav.self_link
  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8"]
  
  allow {
    protocol = "all"
    ports    = []
    }
  }

  resource "google_compute_firewall" "nintendo_switch" {
  name        = "allow-ssh"
  network     = google_compute_network.pokenav.self_link
  direction   = "INGRESS"
  target_tags = ["allow-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "35.235.240.0/20"
  ]
}

resource "google_compute_firewall" "nintendo_global" {
  name          = "allow-http"
  network       = google_compute_network.pokenav.self_link
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]

  allow {
    protocol = "tcp"
    ports = [
      "80", "8080", "443"
    ]
  }
}

resource "google_compute_firewall" "chansey" {
  name          = "allow-chansey"  
  network       = google_compute_network.pokenav.self_link
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  allow {
    protocol = "tcp"
  }
}

#Autohealing
resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "8080"
  }
}

#Instance Template I for Hoenn Region
resource "google_compute_instance_template" "gen1" {
  name = "${var.mig_name}-${var.hoenn}-tmpl"
  machine_type            = var.machine_type
  metadata_startup_script = file("${path.module}/startup/startup.sh")
  region                  = var.hoenn
  tags                    = var.tags
  //[ "http-server","http","https","allow-iap-ssh","allow-http" ]

  scheduling {
    automatic_restart = false
    preemptible       = var.preemptible
  }

  disk {
    source_image = var.rom
    disk_type = var.rom_type
    disk_size_gb = var.rom_size
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.pokenav.self_link
    subnetwork = google_compute_subnetwork.hoenn.self_link
    access_config {
      
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
#Instance Template II for Kanto Region
resource "google_compute_instance_template" "gen2" {

  name                    = "${var.mig_name}-${var.kanto}-tmpl"
  machine_type            = var.machine_type
  metadata_startup_script = file("${path.module}/startup/startup.sh")
  region                  = var.kanto
  tags                    = var.tags
  //[ "http-server","http","allow-incoming","allow-iap-ssh","allow-http"]

  scheduling {
    automatic_restart = false
    preemptible       = var.preemptible
  }

  disk {
    source_image = var.rom
    disk_type = var.rom_type
    disk_size_gb = var.rom_size
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.pokenav.self_link
    subnetwork = google_compute_subnetwork.kanto.self_link
     access_config {
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Instance Group I for Hoenn Region
resource "google_compute_region_instance_group_manager" "mig_group1" {
  name               = "${var.mig_name}-${var.hoenn}-g1"
  region             = var.hoenn
  base_instance_name = var.base_inst
  target_size        = var.targetsize

  version {
    instance_template = google_compute_instance_template.gen1.self_link
    name              = "v1"
  }
  
  named_port {
    name = "http"
    port = 80
  }
  
  named_port {
    name = "https"
    port = 443
  }
}

#Instance Group II for kanto Region
resource "google_compute_region_instance_group_manager" "mig_group2" {
  name               = "${var.mig_name}-${var.kanto}-g2"
  region             = var.kanto
  base_instance_name = var.base_inst
  target_size        = var.targetsize

  version {
    instance_template = google_compute_instance_template.gen2.self_link
    name              = "v2"
  }
  
  named_port {
    name = "http"
    port = 80
  }
  
  named_port {
    name = "https"
    port = 443
  }
}
#Autoscalers
resource "google_compute_region_autoscaler" "evo1" {
  name   = var.hoenn_as
  region = var.hoenn
  target = google_compute_region_instance_group_manager.mig_group1.id

  autoscaling_policy {
    max_replicas    = var.max
    min_replicas    = var.min
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_targetUtil
    }
  }
}


resource "google_compute_region_autoscaler" "evo2" {
  name   = var.kanto_as
  region = var.kanto
  target = google_compute_region_instance_group_manager.mig_group2.id

  autoscaling_policy {
    max_replicas    = var.max
    min_replicas    = var.min
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_targetUtil
    }
  }
}

#Cloud SQL
resource "google_sql_database_instance" "pokedex" {
  name   = var.db_instname
  database_version = var.db_ver
  
  settings {
    tier              = var.tier
    availability_type = "REGIONAL"
    disk_size         = var.rom_size

    backup_configuration {
      binary_log_enabled = true
      enabled = true
    }
    ip_configuration {
      ipv4_enabled    = true
      //private_network = google_compute_network.pokenav.self_link
  }

}

  deletion_protection  = var.del_prot
}

resource "google_sql_database" "dexpss" {
  name     = var.db_name
  instance = google_sql_database_instance.pokedex.name
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_user" "users" {
  name     = var.usrname
  instance = google_sql_database_instance.pokedex.name
  host     = "%"
  password = var.passwd
}