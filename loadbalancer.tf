resource "google_compute_global_forwarding_rule" "loadbalancer" {
  name        = "${var.load_balancer}-fwd-rule"
  port_range  = "80"
  target      = google_compute_target_http_proxy.proxy.id
}

resource "google_compute_target_http_proxy" "proxy" {
  name     = "${var.load_balancer}-fwd-proxy"
  url_map  = google_compute_url_map.pokenav.id
}

resource "google_compute_url_map" "pokenav" {
  name            = var.load_balancer
  default_service = google_compute_backend_service.billpc.id
}

resource "google_compute_backend_service" "billpc" {
  name          = "${var.load_balancer}-backend-service"
  health_checks = [google_compute_http_health_check.nursejoy.id]
  backend {
    group = google_compute_region_instance_group_manager.mig_group1.instance_group
  }
  backend {
    group = google_compute_region_instance_group_manager.mig_group2.instance_group
  }
}

resource "google_compute_http_health_check" "nursejoy" {
  name               = "${var.load_balancer}-chansey"
  request_path       = "/"
  check_interval_sec = 30
  timeout_sec        = 5
}
