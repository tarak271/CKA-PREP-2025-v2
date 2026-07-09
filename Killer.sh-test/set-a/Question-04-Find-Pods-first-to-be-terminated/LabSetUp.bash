#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 4)
rm -f "$DIR/pods-terminated-first.txt"
kubectl create namespace project-c13 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-c13 delete deploy --all --ignore-not-found --wait=false
sleep 1
for dep in c13-2x3-api c13-2x3-web c13-3cc-data c13-3cc-runner-heavy c13-3cc-web; do
  kubectl -n project-c13 create deployment "$dep" --image=nginx:1-alpine --replicas=3 --dry-run=client -o yaml | kubectl apply -f -
done
# Remove resources from runner-heavy pods
kubectl -n project-c13 patch deployment c13-3cc-runner-heavy --type=json -p='[{"op":"remove","path":"/spec/template/spec/containers/0/resources"}]' 2>/dev/null || true
kubectl -n project-c13 rollout status deployment/c13-3cc-runner-heavy --timeout=90s || true

