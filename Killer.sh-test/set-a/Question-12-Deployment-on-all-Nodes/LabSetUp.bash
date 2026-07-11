#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-tiger delete deployment deploy-important --ignore-not-found --wait=false
echo "Ready: namespace project-tiger (create Deployment deploy-important)"

