#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-snake --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-snake delete networkpolicy np-backend --ignore-not-found
kubectl -n project-snake delete pod backend-0 db1-0 db2-0 vault-0 --ignore-not-found --wait=false
kubectl -n project-snake apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: backend-0
  namespace: project-snake
  labels:
    app: backend
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: db1-0
  namespace: project-snake
  labels:
    app: db1
spec:
  containers:
  - name: svc
    image: busybox:1.36
    command: ["sh", "-c", "while true; do { echo -e 'HTTP/1.0 200 OK\r\n\r\ndatabase one'; } | nc -l -p 1111; done"]
---
apiVersion: v1
kind: Pod
metadata:
  name: db2-0
  namespace: project-snake
  labels:
    app: db2
spec:
  containers:
  - name: svc
    image: busybox:1.36
    command: ["sh", "-c", "while true; do { echo -e 'HTTP/1.0 200 OK\r\n\r\ndatabase two'; } | nc -l -p 2222; done"]
---
apiVersion: v1
kind: Pod
metadata:
  name: vault-0
  namespace: project-snake
  labels:
    app: vault
spec:
  containers:
  - name: svc
    image: busybox:1.36
    command: ["sh", "-c", "while true; do { echo -e 'HTTP/1.0 200 OK\r\n\r\nvault secret storage'; } | nc -l -p 3333; done"]
YAML
kubectl -n project-snake wait --for=condition=ready pod --all --timeout=120s || true
echo "Ready: namespace project-snake with backend/db/vault pods (create NetworkPolicy np-backend)"

