#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 4)
rm -f "$DIR/pods-terminated-first.txt"
kubectl create namespace project-c13 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-c13 delete deploy --all --ignore-not-found --wait=false
sleep 2
kubectl -n project-c13 apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: c13-2x3-api
  namespace: project-c13
spec:
  replicas: 3
  selector:
    matchLabels:
      app: c13-2x3-api
  template:
    metadata:
      labels:
        app: c13-2x3-api
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources:
          requests:
            cpu: 50m
            memory: 20Mi
          limits:
            cpu: 50m
            memory: 20Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: c13-2x3-web
  namespace: project-c13
spec:
  replicas: 3
  selector:
    matchLabels:
      app: c13-2x3-web
  template:
    metadata:
      labels:
        app: c13-2x3-web
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources:
          requests:
            cpu: 50m
            memory: 10Mi
          limits:
            cpu: 50m
            memory: 10Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: c13-3cc-data
  namespace: project-c13
spec:
  replicas: 3
  selector:
    matchLabels:
      app: c13-3cc-data
  template:
    metadata:
      labels:
        app: c13-3cc-data
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources:
          requests:
            cpu: 30m
            memory: 10Mi
          limits:
            cpu: 30m
            memory: 10Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: c13-3cc-web
  namespace: project-c13
spec:
  replicas: 3
  selector:
    matchLabels:
      app: c13-3cc-web
  template:
    metadata:
      labels:
        app: c13-3cc-web
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources:
          requests:
            cpu: 50m
            memory: 10Mi
          limits:
            cpu: 50m
            memory: 10Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: c13-3cc-runner-heavy
  namespace: project-c13
spec:
  replicas: 3
  selector:
    matchLabels:
      app: c13-3cc-runner-heavy
  template:
    metadata:
      labels:
        app: c13-3cc-runner-heavy
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources: {}
YAML
kubectl -n project-c13 wait --for=condition=available deployment --all --timeout=120s || true
echo "Ready: project-c13 — c13-3cc-runner-heavy pods have no resource requests (BestEffort)"

