#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-hibiscus --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-hwan delete sa,role,rolebinding --all --ignore-not-found 2>/dev/null || true
kubectl -n project-hibiscus delete sa,role,rolebinding --all --ignore-not-found 2>/dev/null || true

