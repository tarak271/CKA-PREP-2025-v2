#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl delete pod ready-if-service-ready am-i-ready --ignore-not-found --wait=false
kubectl delete svc service-am-i-ready --ignore-not-found
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: service-am-i-ready
  labels:
    id: cross-server-ready
spec:
  selector:
    id: cross-server-ready
  ports:
  - port: 80
YAML

