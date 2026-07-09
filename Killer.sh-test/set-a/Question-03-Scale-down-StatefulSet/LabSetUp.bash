#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-h800 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-h800 delete statefulset o3db --ignore-not-found --wait=false
sleep 1
kubectl -n project-h800 apply -f - <<'YAML'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: o3db
  namespace: project-h800
spec:
  serviceName: o3db
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
YAML
kubectl -n project-h800 wait --for=condition=ready pod -l app=nginx --timeout=120s || true

