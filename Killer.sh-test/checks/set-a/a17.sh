#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -f "$(course_path 17)/pod-container.txt" ]] && pass_task "container-info" "Container ID and runtimeType written" || fail_task "container-info" "Container ID and runtimeType written"
[[ -f "$(course_path 17)/pod-container.log" ]] && pass_task "container-log" "Container logs written" || fail_task "container-log" "Container logs written"


print_summary "a17"
