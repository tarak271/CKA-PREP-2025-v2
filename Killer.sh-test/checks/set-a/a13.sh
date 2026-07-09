#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-r500 get gateway &>/dev/null && pass_task "gateway" "Gateway API resource created" || fail_task "gateway" "Gateway API resource created"
kubectl -n project-r500 get httproute &>/dev/null && pass_task "route" "HTTPRoute created" || fail_task "route" "HTTPRoute created"


print_summary "a13"
