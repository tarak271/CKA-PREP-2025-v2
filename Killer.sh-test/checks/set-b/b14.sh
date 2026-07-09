#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


FILE="$(course_path 14)/cluster-info"
[[ -f "$FILE" ]] && pass_task "info" "Cluster info file created" || fail_task "info" "Cluster info file created"
grep -qi version "$FILE" 2>/dev/null && pass_task "version" "Cluster version documented" || fail_task "version" "Cluster version documented"
grep -qi node "$FILE" 2>/dev/null && pass_task "nodes" "Node info documented" || fail_task "nodes" "Node info documented"


print_summary "b14"
