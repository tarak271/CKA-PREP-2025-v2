#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl delete pod pod1 --ignore-not-found --wait=false
echo "Create Pod pod1 (httpd:2-alpine) scheduled on control-plane node"

