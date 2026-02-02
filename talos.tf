# Generate Talos machine secrets
resource "talos_machine_secrets" "this" {}

# Generate client configuration
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.controlplane_ips
}

# Control plane machine configuration
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cluster_endpoint}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = var.worker_count == 0
      }
      machine = {
        install = {
          disk = "/dev/sda"
        }
        kubelet = {
          extraArgs = {
            "rotate-server-certificates" = true
          }
        }
      }
    })
  ]
}

# Worker machine configuration
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cluster_endpoint}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sda"
        }
        kubelet = {
          extraArgs = {
            "rotate-server-certificates" = true
          }
        }
      }
    })
  ]
}

# Apply configuration to control plane nodes
resource "talos_machine_configuration_apply" "controlplane" {
  count = var.controlplane_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.controlplane_ips[count.index]

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = "ens18"
              addresses = ["${local.controlplane_ips[count.index]}/${var.network_cidr}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.network_gateway
                }
              ]
            }
          ]
          nameservers = var.network_nameservers
        }
        time = {
          servers = var.ntp_servers
        }
      }
    })
  ]

  depends_on = [proxmox_virtual_environment_vm.controlplane]
}

# Apply configuration to worker nodes
resource "talos_machine_configuration_apply" "worker" {
  count = var.worker_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = local.worker_ips[count.index]

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = "ens18"
              addresses = ["${local.worker_ips[count.index]}/${var.network_cidr}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.network_gateway
                }
              ]
            }
          ]
          nameservers = var.network_nameservers
        }
        time = {
          servers = var.ntp_servers
        }
      }
    })
  ]

  depends_on = [proxmox_virtual_environment_vm.worker]
}

# Bootstrap the cluster
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_ips[0]

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# Get kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_ips[0]

  depends_on = [talos_machine_bootstrap.this]
}
