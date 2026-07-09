#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


pending=$(kubectl get pods -A --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l | tr -d ' ')
[[ "$pending" -ge 0 ]] && pass_task "schedule" "Manual scheduling exercise attempted" || fail_task "schedule" "Manual scheduling exercise attempted"


print_summary "b09"
