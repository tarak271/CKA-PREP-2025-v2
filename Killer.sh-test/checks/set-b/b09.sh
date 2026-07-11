#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pod manual-schedule &>/dev/null && pass_task "pod1" "Pod manual-schedule exists" ||           fail_task "pod1" "Pod manual-schedule exists"
node1=$(kubectl get pod manual-schedule -o jsonpath='{.spec.nodeName}' 2>/dev/null)
[[ -n "$node1" ]] && pass_task "scheduled1" "manual-schedule assigned to a node" ||           fail_task "scheduled1" "manual-schedule assigned to a node"
kubectl get pod manual-schedule2 &>/dev/null && pass_task "pod2" "Pod manual-schedule2 exists" ||           fail_task "pod2" "Pod manual-schedule2 exists"
phase=$(kubectl get pod manual-schedule2 -o jsonpath='{.status.phase}' 2>/dev/null)
[[ "$phase" == "Running" ]] && pass_task "running2" "manual-schedule2 is Running" ||           fail_task "running2" "manual-schedule2 is Running"


print_summary "b09"
