# Proxmox Connection
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_username" {
  description = "Proxmox username (e.g., root@pam) - used if api_token is empty"
  type        = string
  default     = ""
}

variable "proxmox_password" {
  description = "Proxmox password - used if api_token is empty"
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = false
}

variable "proxmox_node" {
  description = "Proxmox node name to deploy VMs on"
  type        = string
}

# Cluster Configuration
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "talos-cluster"
}

variable "cluster_endpoint" {
  description = "Kubernetes API endpoint (IP or hostname for control plane)"
  type        = string
}

# Talos Configuration
variable "talos_version" {
  description = "Talos Linux version"
  type        = string
  default     = "v1.7.0"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30.0"
}

# Control Plane Nodes
variable "controlplane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
}

variable "controlplane_cores" {
  description = "Number of CPU cores for control plane nodes"
  type        = number
  default     = 2
}

variable "controlplane_memory" {
  description = "Memory in MB for control plane nodes"
  type        = number
  default     = 4096
}

variable "controlplane_disk_size" {
  description = "Disk size in GB for control plane nodes"
  type        = number
  default     = 50
}

variable "controlplane_ip_start" {
  description = "Starting IP address for control plane nodes (e.g., 192.168.1.10) - used if controlplane_ips is empty"
  type        = string
  default     = ""
}

variable "controlplane_ips" {
  description = "Explicit list of control plane IPs (overrides controlplane_ip_start)"
  type        = list(string)
  default     = []
}

# Worker Nodes
variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "worker_cores" {
  description = "Number of CPU cores for worker nodes"
  type        = number
  default     = 4
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
  default     = 8192
}

variable "worker_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 100
}

variable "worker_ip_start" {
  description = "Starting IP address for worker nodes (e.g., 192.168.1.20) - used if worker_ips is empty"
  type        = string
  default     = ""
}

variable "worker_ips" {
  description = "Explicit list of worker IPs (overrides worker_ip_start)"
  type        = list(string)
  default     = []
}

# Network Configuration
variable "network_gateway" {
  description = "Network gateway IP"
  type        = string
}

variable "network_nameservers" {
  description = "DNS nameservers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "ntp_servers" {
  description = "NTP servers for time sync"
  type        = list(string)
  default     = ["time.cloudflare.com", "pool.ntp.org"]
}

variable "network_cidr" {
  description = "Network CIDR prefix length"
  type        = number
  default     = 24
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}

# Storage
variable "storage_pool" {
  description = "Proxmox storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "iso_storage" {
  description = "Proxmox storage pool for ISO images"
  type        = string
  default     = "local"
}

variable "talos_iso_file" {
  description = "Pre-uploaded Talos ISO file ID (e.g., 'local:iso/talos-v1.7.0-amd64.iso'). If set, skips download."
  type        = string
  default     = ""
}
