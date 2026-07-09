#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get ds ds-overlord &>/dev/null && pass_task "ds" "DaemonSet ds-overlord exists" || fail_task "ds" "DaemonSet ds-overlord exists"
nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
ready=$(kubectl get ds ds-overlord -o jsonpath='{.status.numberReady}' 2>/dev/null || echo 0)
[[ "$ready" -ge 1 ]] && pass_task "scheduled" "DaemonSet scheduled on nodes" || fail_task "scheduled" "DaemonSet scheduled on nodes"


print_summary "a11"
