#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace lima-control lima-workload --dry-run=client -o yaml | kubectl apply -f -
kubectl -n lima-control delete deploy,cm --all --ignore-not-found --wait=false
kubectl -n lima-workload delete pod,svc --all --ignore-not-found --wait=false
sleep 2
kubectl -n lima-workload apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: department
  namespace: lima-workload
spec:
  clusterIP: None
  selector:
    app: dept
  ports:
  - port: 80
---
apiVersion: v1
kind: Service
metadata:
  name: section
  namespace: lima-workload
spec:
  selector:
    name: section
  ports:
  - port: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: section100
  namespace: lima-workload
  labels:
    name: section
spec:
  hostname: section100
  subdomain: section
  containers:
  - name: pod
    image: httpd:2-alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: section200
  namespace: lima-workload
  labels:
    name: section
spec:
  hostname: section200
  subdomain: section
  containers:
  - name: pod
    image: httpd:2-alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: dept-a
  namespace: lima-workload
  labels:
    app: dept
spec:
  containers:
  - name: pod
    image: httpd:2-alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: dept-b
  namespace: lima-workload
  labels:
    app: dept
spec:
  containers:
  - name: pod
    image: httpd:2-alpine
YAML
kubectl -n lima-control apply -f - <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: control-config
  namespace: lima-control
data:
  DNS_1: "CHANGE_ME"
  DNS_2: "CHANGE_ME"
  DNS_3: "CHANGE_ME"
  DNS_4: "CHANGE_ME"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller
  namespace: lima-control
spec:
  replicas: 1
  selector:
    matchLabels:
      app: controller
  template:
    metadata:
      labels:
        app: controller
    spec:
      containers:
      - name: controller
        image: busybox:1.36
        command: ["sh", "-c", "while true; do for k in DNS_1 DNS_2 DNS_3 DNS_4; do v=$(cat /config/$k); echo + nslookup $v; nslookup $v || true; done; sleep 30; done"]
        envFrom:
        - configMapRef:
            name: control-config
        volumeMounts:
        - name: cfg
          mountPath: /config
      volumes:
      - name: cfg
        configMap:
          name: control-config
YAML

