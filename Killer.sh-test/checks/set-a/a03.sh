#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


replicas=$(kubectl -n project-h800 get sts o3db -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
if [[ "$replicas" == "1" ]]; then
  pass_task "scale" "StatefulSet o3db scaled to 1 replica"
else
  fail_task "scale" "StatefulSet o3db scaled to 1 replica" "kubectl -n project-h800 scale sts o3db --replicas 1"
fi


print_summary "a03"
