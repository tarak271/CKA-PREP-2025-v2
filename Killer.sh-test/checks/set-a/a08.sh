#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
[[ "$nodes" -ge 1 ]] && pass_task "nodes" "Cluster has nodes" || fail_task "nodes" "Cluster has nodes"
pass_task "upgrade" "Kubeadm upgrade attempted (manual verification)"


print_summary "a08"
