# Talos Kubernetes Cluster Operations Guide

## Node Management

### Add control plane nodes

```bash
# Update terraform.tfvars
controlplane_count = 3
controlplane_ips = ["192.168.0.169", "192.168.0.171", "192.168.0.172"]

# Apply
tofu apply
```

### Add worker nodes

```bash
# Update terraform.tfvars
worker_count = 4
worker_ips = ["192.168.0.170", "192.168.0.168", "192.168.0.173", "192.168.0.174"]

# Apply
tofu apply
```

### Remove nodes

```bash
# First drain the node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --kubeconfig=kubeconfig.yaml

# Update terraform.tfvars (reduce count/remove IP)
# Then apply
tofu apply
```

---

## Cluster Upgrades

### Upgrade Talos

```bash
# Check current version
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 version

# Upgrade (control plane first, then workers)
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 upgrade \
  --image ghcr.io/siderolabs/installer:v1.8.0

# Or update terraform.tfvars and apply
talos_version = "v1.8.0"
tofu apply
```

### Upgrade Kubernetes

```bash
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 upgrade-k8s \
  --to 1.31.0
```

---

## Cluster Health & Troubleshooting

```bash
# Health check
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 health

# Interactive dashboard
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 dashboard

# View logs
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 logs kubelet
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 dmesg

# Get node config
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 get machineconfig

# Reboot a node
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 reboot

# Reset a node (wipes it)
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 reset --graceful
```

---

## Certificate Management

```bash
# Approve pending CSRs (needed after node restarts)
kubectl get csr --kubeconfig=kubeconfig.yaml
kubectl certificate approve <csr-name> --kubeconfig=kubeconfig.yaml

# Approve all pending
kubectl get csr --kubeconfig=kubeconfig.yaml -o name | xargs kubectl certificate approve --kubeconfig=kubeconfig.yaml
```

---

## Deploy ArgoCD

```bash
# Create namespace
kubectl create namespace argocd --kubeconfig=kubeconfig.yaml

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --kubeconfig=kubeconfig.yaml

# Wait for pods
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s --kubeconfig=kubeconfig.yaml

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --kubeconfig=kubeconfig.yaml | base64 -d

# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 --kubeconfig=kubeconfig.yaml
# Access at https://localhost:8080 (user: admin)
```

---

## Deploy Other Common Tools

### Helm

```bash
# Install Helm (if not installed)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Use with your kubeconfig
export KUBECONFIG=$PWD/kubeconfig.yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/nginx
```

### Metrics Server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --kubeconfig=kubeconfig.yaml
```

### Ingress (NGINX)

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --kubeconfig=kubeconfig.yaml
```

### Cert-Manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml --kubeconfig=kubeconfig.yaml
```

---

## Backup & Restore

### Backup etcd

```bash
talosctl --talosconfig=talosconfig.yaml -n 192.168.0.169 etcd snapshot db.snapshot
```

### Backup Talos config

```bash
# Already in your tofu state, but also:
cp talosconfig.yaml talosconfig.yaml.backup
cp kubeconfig.yaml kubeconfig.yaml.backup
tofu state pull > terraform.tfstate.backup
```

---

## Destroy Cluster

```bash
# Destroy all resources
tofu destroy

# Or just remove specific nodes by updating tfvars and applying
```

---

## Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export KUBECONFIG=/home/jonathan/claude-code-trial/kubeconfig.yaml
export TALOSCONFIG=/home/jonathan/claude-code-trial/talosconfig.yaml
alias tc="talosctl --talosconfig=$TALOSCONFIG"
alias k="kubectl --kubeconfig=$KUBECONFIG"
```

Then use: `k get pods`, `tc -n 192.168.0.169 dashboard`
