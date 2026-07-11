#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


FILE="$(course_path 4)/pods-terminated-first.txt"
besteffort=$(kubectl -n project-c13 get pods -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' 2>/dev/null | grep -c 'c13-3cc-runner-heavy' || echo 0)
burstable=$(kubectl -n project-c13 get pods -o jsonpath='{range .items[?(@.status.qosClass=="Burstable")]}{.metadata.name}{"\n"}{end}' 2>/dev/null | wc -l | tr -d ' ')
if [[ "${besteffort:-0}" -ge 1 && "${burstable:-0}" -ge 1 ]]; then
  pass_task "lab-state" "Runner-heavy pods are BestEffort; other pods have requests"
else
  fail_task "lab-state" "Runner-heavy pods are BestEffort; other pods have requests"             "Re-run lab setup: bash Killer.sh-test/set-a/Question-04-.../LabSetUp.bash"
fi
if [[ ! -f "$FILE" ]]; then
  fail_task "pods-file" "Pod names written to pods-terminated-first.txt"
else
  got=$(sort "$FILE" | grep -v '^$' || true)
  if [[ -n "$got" ]] && echo "$got" | grep -q "c13-3cc-runner-heavy"; then
    pass_task "pods-file" "Pods without resource requests identified"
  else
    fail_task "pods-file" "Pods without resource requests identified"               "Write c13-3cc-runner-heavy pod names (BestEffort) to $FILE"
  fi
fi


print_summary "a04"
