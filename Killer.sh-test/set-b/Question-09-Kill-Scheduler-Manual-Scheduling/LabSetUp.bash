#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl delete pod manual-schedule manual-schedule2 --ignore-not-found --wait=false
echo "Manual scheduling scenario — temporarily stop kube-scheduler if needed."

