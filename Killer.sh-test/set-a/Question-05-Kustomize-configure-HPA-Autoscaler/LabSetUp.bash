#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 5)
rm -rf "$DIR/api-gateway"
mkdir -p "$DIR/api-gateway/base" "$DIR/api-gateway/staging" "$DIR/api-gateway/prod"
cat > "$DIR/api-gateway/base/kustomization.yaml" <<'YAML'
resources:
  - api-gateway.yaml
YAML
cat > "$DIR/api-gateway/base/api-gateway.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api
        image: nginx:1-alpine
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  placeholder: "true"
YAML
cat > "$DIR/api-gateway/staging/kustomization.yaml" <<'YAML'
namespace: api-gateway-staging
resources:
  - ../base
YAML
cat > "$DIR/api-gateway/prod/kustomization.yaml" <<'YAML'
namespace: api-gateway-prod
resources:
  - ../base
YAML
kubectl delete namespace api-gateway-staging api-gateway-prod --ignore-not-found --wait=false

