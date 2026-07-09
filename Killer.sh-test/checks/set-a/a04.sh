#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


FILE="$(course_path 4)/pods-terminated-first.txt"
if [[ ! -f "$FILE" ]]; then
  fail_task "pods-file" "Pod names written to pods-terminated-first.txt"
else
  # Expect pods from c13-3cc-runner-heavy deployment (BestEffort QoS)
  expected=$(kubectl -n project-c13 get pods -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' 2>/dev/null | sort)
  got=$(sort "$FILE" | grep -v '^$' || true)
  if [[ -n "$got" ]] && echo "$got" | grep -q "c13-3cc-runner-heavy"; then
    pass_task "pods-file" "Pods without resource requests identified"
  else
    fail_task "pods-file" "Pods without resource requests identified" "Write BestEffort pod names to $FILE"
  fi
fi


print_summary "a04"
