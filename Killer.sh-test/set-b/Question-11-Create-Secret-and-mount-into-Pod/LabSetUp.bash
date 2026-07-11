#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 11)
kubectl create namespace secret --dry-run=client -o yaml | kubectl apply -f -
kubectl -n secret delete pod secret-pod secret secret1 secret2 --ignore-not-found --wait=false
cat > "$DIR/secret1.yaml" <<'YAML'
apiVersion: v1
kind: Secret
metadata:
  name: secret1
  namespace: secret
type: Opaque
data:
  key1: dmFsdWUx
YAML
echo "Ready: namespace secret with secret1.yaml fixture (create secret-pod, secret2, mounts)"

