#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -x "$(course_path 15)/cluster_events.sh" ]] && pass_task "events-sh" "cluster_events.sh created" || fail_task "events-sh" "cluster_events.sh created"
[[ -f "$(course_path 15)/pod_kill.log" ]] && pass_task "pod-log" "pod_kill.log created" || fail_task "pod-log" "pod_kill.log created"
[[ -f "$(course_path 15)/container_kill.log" ]] && pass_task "container-log" "container_kill.log created" || fail_task "container-log" "container_kill.log created"


print_summary "b15"
