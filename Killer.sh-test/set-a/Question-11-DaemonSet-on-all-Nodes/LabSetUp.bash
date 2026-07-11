#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 11)
kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false
echo "Ready: namespace project-tiger (create DaemonSet ds-important)"

