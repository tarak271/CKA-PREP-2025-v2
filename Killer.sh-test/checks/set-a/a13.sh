#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-r500 get gateway main &>/dev/null && pass_task "gateway" "Gateway main exists in project-r500" ||           fail_task "gateway" "Gateway main exists in project-r500"
kubectl -n project-r500 get httproute traffic-director &>/dev/null && pass_task "route" "HTTPRoute traffic-director created" ||           fail_task "route" "HTTPRoute traffic-director created"
kubectl -n project-r500 get svc web-desktop web-mobile &>/dev/null && pass_task "backends" "Backend services web-desktop and web-mobile exist" ||           fail_task "backends" "Backend services web-desktop and web-mobile exist"


print_summary "a13"
