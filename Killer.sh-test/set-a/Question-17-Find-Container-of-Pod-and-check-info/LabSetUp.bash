#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 17)
rm -f "$DIR/pod-container.txt" "$DIR/pod-container.log"
kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-tiger delete pod tigers-reunite --ignore-not-found --wait=false
echo "Ready: namespace project-tiger (create Pod tigers-reunite, then inspect with crictl)"

