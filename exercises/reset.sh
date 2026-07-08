#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/cluster-reset.sh"

# 1. Stop and disable cri-dockerd services
sudo systemctl stop cri-docker.socket
sudo systemctl stop cri-docker.service
sudo systemctl disable cri-docker.socket cri-docker.service

# 2. Purge the debian package and configuration files
sudo apt purge cri-dockerd -y

# 3. Clean up residual files and directories
sudo rm -rf /var/run/cri-dockerd.sock
sudo rm -rf /etc/systemd/system/cri-docker.service
sudo rm -rf /etc/systemd/system/cri-docker.socket

# 4. Refresh systemd daemon state
sudo systemctl daemon-reload
sudo systemctl reset-failed


echo "=== [1/6] Tearing down existing Kubernetes environment ==="
sudo kubeadm reset -f

echo "=== [2/6] Cleaning up system network paths ==="
sudo ip link set cni0 down 2>/dev/null || true
sudo ip link delete cni0 2>/dev/null || true
sudo ip link set flannel.1 down 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true

sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
sudo ipvsadm -C 2>/dev/null || true

echo "=== [3/6] Purging leftover state directories ==="
sudo rm -rf /etc/cni /var/lib/cni/ /var/lib/kubelet/ /etc/kubernetes/
rm -rf "$HOME/.kube"

echo "=== [4/6] Cycle container runtime state ==="
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "=== [5/6] Re-initializing single-node cluster ==="
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "=== [6/6] Configuring single-node cluster networking ==="
kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true

echo "Deploying Flannel CNI..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml

echo "Waiting for core system pods to be ready..."
kubectl wait --namespace=kube-system --for=condition=Ready pods --all --timeout=120s
kubectl wait --namespace=kube-flannel --for=condition=Ready pods --all --timeout=120s 2>/dev/null || true

verify_cluster_clean

echo "========================================="
echo " SUCCESS: Single-node cluster is fresh and ready!"
echo "========================================="
