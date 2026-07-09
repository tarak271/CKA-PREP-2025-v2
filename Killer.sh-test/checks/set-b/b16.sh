#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -f "$(course_path 16)/resources.txt" ]] && pass_task "resources" "Namespaced API resources listed" || fail_task "resources" "Namespaced API resources listed"
[[ -f "$(course_path 16)/crowded-namespace.txt" ]] && pass_task "crowded" "Crowded namespace identified" || fail_task "crowded" "Crowded namespace identified"


print_summary "b16"
