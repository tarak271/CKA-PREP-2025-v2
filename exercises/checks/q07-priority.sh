#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: PriorityClass high-priority with value 999
if kubectl get priorityclass high-priority &>/dev/null; then
  value=$(kubectl get priorityclass high-priority -o jsonpath='{.value}' 2>/dev/null)
  if [[ "$value" == "999" ]]; then
    pass_task "priority-class" "PriorityClass high-priority created with value 999"
  else
    fail_task "priority-class" "PriorityClass high-priority created with value 999" \
      "Current value: $value (expected 999, one less than user-critical at 1000)"
  fi
else
  fail_task "priority-class" "PriorityClass high-priority created with value 999" \
    "Run: kubectl create priorityclass high-priority --value=999"
fi

# Task 2: Deployment uses priority class
pcn=$(kubectl get deployment busybox-logger -n priority -o jsonpath='{.spec.template.spec.priorityClassName}' 2>/dev/null)
if [[ "$pcn" == "high-priority" ]]; then
  pass_task "deployment-patched" "Deployment busybox-logger uses high-priority class"
else
  fail_task "deployment-patched" "Deployment busybox-logger uses high-priority class" \
    "Patch deployment to set priorityClassName: high-priority"
fi

print_summary "q07"
