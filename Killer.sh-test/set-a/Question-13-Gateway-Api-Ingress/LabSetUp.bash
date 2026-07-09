#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 13)
kubectl create namespace project-r500 --dry-run=client -o yaml | kubectl apply -f -
cat > "$DIR/ingress.yaml" <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: r500-ingress
  namespace: project-r500
spec:
  rules:
  - host: r500.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: r500-svc
            port:
              number: 80
YAML
kubectl -n project-r500 apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: r500-svc
  namespace: project-r500
spec:
  selector:
    app: r500
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: r500
  namespace: project-r500
spec:
  replicas: 1
  selector:
    matchLabels:
      app: r500
  template:
    metadata:
      labels:
        app: r500
    spec:
      containers:
      - name: web
        image: nginx:1-alpine
YAML
kubectl -n project-r500 apply -f "$DIR/ingress.yaml" || true

