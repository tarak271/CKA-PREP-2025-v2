#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 17)
rm -f "$DIR/pod-container.txt" "$DIR/pod-container.log"
kubectl create namespace project-park --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-park delete pod gherkin --ignore-not-found --wait=false
kubectl -n project-park apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: gherkin
  namespace: project-park
spec:
  containers:
  - name: cucumber
    image: busybox:1.36
    command: ["sh", "-c", "echo hello-from-cucumber; sleep 3600"]
  - name: tomato
    image: busybox:1.36
    command: ["sleep", "3600"]
YAML
kubectl -n project-park wait --for=condition=ready pod/gherkin --timeout=60s || true

