#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-hamster --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-hamster delete sa processor role processor rolebinding processor           --ignore-not-found 2>/dev/null || true
echo "Ready: namespace project-hamster (create SA/Role/RoleBinding named processor)"

