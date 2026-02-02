# Download Talos ISO (only if talos_iso_file is not provided)
resource "proxmox_virtual_environment_download_file" "talos_iso" {
  count = var.talos_iso_file == "" ? 1 : 0

  content_type = "iso"
  datastore_id = var.iso_storage
  node_name    = var.proxmox_node
  url          = "https://github.com/siderolabs/talos/releases/download/${var.talos_version}/talos-amd64.iso"
  file_name    = "talos-${var.talos_version}-amd64.iso"
}

locals {
  talos_iso_id = var.talos_iso_file != "" ? var.talos_iso_file : proxmox_virtual_environment_download_file.talos_iso[0].id

  # Use explicit IPs if provided, otherwise calculate from start IP
  controlplane_ips = length(var.controlplane_ips) > 0 ? var.controlplane_ips : [
    for i in range(var.controlplane_count) : cidrhost("${var.controlplane_ip_start}/${var.network_cidr}", i)
  ]
  worker_ips = length(var.worker_ips) > 0 ? var.worker_ips : [
    for i in range(var.worker_count) : cidrhost("${var.worker_ip_start}/${var.network_cidr}", i)
  ]
}

# Control Plane VMs
resource "proxmox_virtual_environment_vm" "controlplane" {
  count = var.controlplane_count

  name      = "${var.cluster_name}-cp-${count.index}"
  node_name = var.proxmox_node
  vm_id     = 8000 + count.index

  machine = "q35"
  bios    = "seabios"

  agent {
    enabled = false
  }

  cpu {
    cores = var.controlplane_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.controlplane_memory
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  disk {
    datastore_id = var.storage_pool
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.controlplane_disk_size
    ssd          = true
    discard      = "on"
  }

  cdrom {
    file_id   = local.talos_iso_id
    interface = "ide2"
  }

  boot_order = ["scsi0", "ide2"]

  operating_system {
    type = "l26"
  }

  # Note: Talos doesn't use cloud-init, IPs are configured via Talos machine config

  lifecycle {
    ignore_changes = [
      cdrom,
      boot_order,
    ]
  }
}

# Worker VMs
resource "proxmox_virtual_environment_vm" "worker" {
  count = var.worker_count

  name      = "${var.cluster_name}-worker-${count.index}"
  node_name = var.proxmox_node
  vm_id     = 8100 + count.index

  machine = "q35"
  bios    = "seabios"

  agent {
    enabled = false
  }

  cpu {
    cores = var.worker_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.worker_memory
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  disk {
    datastore_id = var.storage_pool
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.worker_disk_size
    ssd          = true
    discard      = "on"
  }

  cdrom {
    file_id   = local.talos_iso_id
    interface = "ide2"
  }

  boot_order = ["scsi0", "ide2"]

  operating_system {
    type = "l26"
  }

  # Note: Talos doesn't use cloud-init, IPs are configured via Talos machine config

  lifecycle {
    ignore_changes = [
      cdrom,
      boot_order,
    ]
  }
}
