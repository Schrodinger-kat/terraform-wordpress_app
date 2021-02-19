output "network" {
  value       = google_compute_network.pokenav
  description = "The VPC resource"
}

output "network_name" {
  value       = google_compute_network.pokenav.name
  description = "The name of the VPC"
}

output "network_self_link" {
  value       = google_compute_network.pokenav.self_link
  description = "The URI of the VPC"
}

output "backend_services" {
  description = "The backend service resources."
  value       = google_compute_backend_service.billpc
}

output "instance_ip_address" {
  value       = google_sql_database_instance.pokedex.ip_address
  description = "The IPv4 address assigned for the master instance"
}