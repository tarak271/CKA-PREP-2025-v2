#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: API server etcd endpoint fixed
apiserver_manifest="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [[ -f "$apiserver_manifest" ]] || [[ -f /root/kube-apiserver.yaml.bak ]]; then
  manifest="$apiserver_manifest"
  [[ ! -r "$manifest" ]] && manifest="/root/kube-apiserver.yaml.bak"
  if grep -q '2379' "$manifest" 2>/dev/null && ! grep -q ':2380' "$manifest" 2>/dev/null; then
    pass_task "api-server-fixed" "kube-apiserver etcd endpoint fixed (port 2379)"
  elif grep -q '2379' "$manifest" 2>/dev/null; then
    pass_task "api-server-fixed" "kube-apiserver etcd endpoint fixed (port 2379)"
  else
    fail_task "api-server-fixed" "kube-apiserver etcd endpoint fixed (port 2379)" \
      "Edit /etc/kubernetes/manifests/kube-apiserver.yaml — use etcd port 2379 not 2380"
  fi
else
  fail_task "api-server-fixed" "kube-apiserver etcd endpoint fixed (port 2379)" \
    "Cannot read kube-apiserver manifest"
fi

# Task 2: Cluster healthy
if kubectl get nodes &>/dev/null && [[ $(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ') -ge 1 ]]; then
  pass_task "cluster-healthy" "Cluster is healthy (kubectl get nodes succeeds)"
else
  fail_task "cluster-healthy" "Cluster is healthy (kubectl get nodes succeeds)" \
    "API server is not responding. Fix etcd endpoint and wait for kube-apiserver to restart."
fi

print_summary "q15"
[[ $FAIL -eq 0 ]]
