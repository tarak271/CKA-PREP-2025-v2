#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-t230 --dry-run=client -o yaml | kubectl apply -f -
kubectl delete pv safari-pv --ignore-not-found
kubectl -n project-t230 delete deploy safari pvc safari-pvc --ignore-not-found --wait=false

