#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


echo "Kubeadm upgrade scenario — work on control-plane node."
echo "Current version: $(kubectl version --short 2>/dev/null || kubectl version 2>/dev/null | head -1)"

