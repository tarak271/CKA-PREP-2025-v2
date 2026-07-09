#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


count=$(kubectl -n project-tiger get networkpolicy --no-headers 2>/dev/null | wc -l | tr -d ' ')
[[ "$count" -ge 1 ]] && pass_task "netpol" "NetworkPolicy created in project-tiger" || fail_task "netpol" "NetworkPolicy created in project-tiger"


print_summary "a15"
