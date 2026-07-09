#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 9)
rm -f "$DIR/result.json"
kubectl create namespace project-swan --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-swan delete pod api-contact --ignore-not-found --wait=false
kubectl -n project-swan apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: api-contact
  namespace: project-swan
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
YAML
kubectl -n project-swan wait --for=condition=ready pod/api-contact --timeout=60s || true

