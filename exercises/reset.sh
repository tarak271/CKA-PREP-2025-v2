#!/bin/bash
# Full cluster reset — idempotent; safe to run multiple times.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/safe-ops.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/cluster-reset.sh"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

cleanup_cri_docker

echo "=== [1/6] Tearing down existing Kubernetes environment ==="
sudo kubeadm reset -f || safe_note "kubeadm reset completed with warnings (may already be clean)"

echo "=== [2/6] Cleaning up system network paths ==="
safe_ip_link_delete cni0
safe_ip_link_delete flannel.1
safe_iptables_flush
safe_run "ipvsadm clear" sudo ipvsadm -C

echo "=== [3/6] Purging leftover state directories ==="
safe_rm /etc/cni /var/lib/cni /var/lib/kubelet /etc/kubernetes
rm -rf "$HOME/.kube" 2>/dev/null || true

echo "=== [4/6] Cycle container runtime state ==="
sudo systemctl restart containerd || fail "containerd restart failed"
sudo systemctl restart kubelet || safe_note "kubelet restart skipped (may not exist yet)"

echo "=== [5/6] Re-initializing single-node cluster ==="
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 || fail "kubeadm init failed"

mkdir -p "$HOME/.kube"
sudo cp -f /etc/kubernetes/admin.conf "$HOME/.kube/config" 2>/dev/null || \
  fail "could not copy admin.conf to ~/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "=== [6/6] Configuring single-node cluster networking ==="
kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true

echo "Deploying Flannel CNI..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml \
  || fail "Flannel install failed"

echo "Waiting for core system pods to be ready..."
kubectl wait --namespace=kube-system --for=condition=Ready pods --all --timeout=120s \
  || safe_note "some kube-system pods not Ready within timeout"
kubectl wait --namespace=kube-flannel --for=condition=Ready pods --all --timeout=120s 2>/dev/null \
  || safe_note "kube-flannel pods not Ready within timeout (may still be starting)"

verify_cluster_clean || fail "cluster verification failed"

echo "========================================="
echo " SUCCESS: Single-node cluster is fresh and ready!"
echo "========================================="
