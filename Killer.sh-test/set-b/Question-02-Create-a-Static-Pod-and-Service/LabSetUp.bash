#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl delete svc static-pod-service --ignore-not-found
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
MANIFEST_DIR="/etc/kubernetes/manifests"
if [[ -w "$MANIFEST_DIR" ]] || sudo test -w "$MANIFEST_DIR"; then
  sudo rm -f "$MANIFEST_DIR/my-static-pod.yaml" 2>/dev/null || rm -f "$MANIFEST_DIR/my-static-pod.yaml" 2>/dev/null || true
fi
echo "Create static pod my-static-pod in $MANIFEST_DIR on node $NODE"

