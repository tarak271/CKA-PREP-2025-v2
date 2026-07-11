#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-snake get networkpolicy np-backend &>/dev/null &&           pass_task "netpol" "NetworkPolicy np-backend exists in project-snake" ||           fail_task "netpol" "NetworkPolicy np-backend exists in project-snake"
sel=$(kubectl -n project-snake get networkpolicy np-backend -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
[[ "$sel" == "backend" ]] && pass_task "selector" "NetworkPolicy selects app=backend pods" ||           fail_task "selector" "NetworkPolicy selects app=backend pods"


print_summary "a15"
