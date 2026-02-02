terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}
