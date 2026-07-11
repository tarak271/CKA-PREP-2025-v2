#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 13)
kubectl create namespace project-r500 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-r500 delete httproute traffic-director ingress traffic-director --ignore-not-found --wait=false

cat > "$DIR/ingress.yaml" <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traffic-director
  namespace: project-r500
spec:
  ingressClassName: nginx
  rules:
  - host: r500.gateway
    http:
      paths:
      - path: /desktop
        pathType: Prefix
        backend:
          service:
            name: web-desktop
            port:
              number: 80
      - path: /mobile
        pathType: Prefix
        backend:
          service:
            name: web-mobile
            port:
              number: 80
YAML

kubectl -n project-r500 apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: web-desktop
  namespace: project-r500
spec:
  selector:
    app: web-desktop
  ports:
  - port: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-mobile
  namespace: project-r500
spec:
  selector:
    app: web-mobile
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-desktop
  namespace: project-r500
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-desktop
  template:
    metadata:
      labels:
        app: web-desktop
    spec:
      containers:
      - name: web
        image: nginx:1-alpine
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-mobile
  namespace: project-r500
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-mobile
  template:
    metadata:
      labels:
        app: web-mobile
    spec:
      containers:
      - name: web
        image: nginx:1-alpine
YAML
kubectl -n project-r500 apply -f "$DIR/ingress.yaml" || true

if kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  kubectl -n project-r500 apply -f - <<'YAML' || true
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main
  namespace: project-r500
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
YAML
else
  echo "Note: Gateway API CRDs not installed — install a Gateway controller for full Q13"
fi

