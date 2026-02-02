provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token != "" ? var.proxmox_api_token : null
  username  = var.proxmox_username != "" ? var.proxmox_username : null
  password  = var.proxmox_password != "" ? var.proxmox_password : null
  insecure  = var.proxmox_insecure
}

provider "talos" {}
