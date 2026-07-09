#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


echo "Kubelet troubleshooting scenario on this node."
systemctl is-active kubelet &>/dev/null && echo "kubelet is active" || echo "kubelet may need fixing"

