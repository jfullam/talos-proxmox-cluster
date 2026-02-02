output "talosconfig" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes admin kubeconfig"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "controlplane_ips" {
  description = "Control plane node IP addresses"
  value       = local.controlplane_ips
}

output "worker_ips" {
  description = "Worker node IP addresses"
  value       = local.worker_ips
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://${var.cluster_endpoint}:6443"
}
