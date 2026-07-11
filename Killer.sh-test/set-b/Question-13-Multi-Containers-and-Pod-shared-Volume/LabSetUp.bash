#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl delete pod multi-container-playground --ignore-not-found --wait=false
echo "Create Pod multi-container-playground with shared volume in default"

