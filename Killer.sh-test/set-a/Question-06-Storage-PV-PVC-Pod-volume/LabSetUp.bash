#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


kubectl create namespace project-t230 --dry-run=client -o yaml | kubectl apply -f -
cleanup_safari_storage

