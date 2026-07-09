#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pod ready-if-service-ready &>/dev/null && pass_task "pod1" "Pod ready-if-service-ready exists" || fail_task "pod1" "Pod ready-if-service-ready exists"
kubectl get pod am-i-ready &>/dev/null && pass_task "pod2" "Pod am-i-ready exists" || fail_task "pod2" "Pod am-i-ready exists"
ready=$(kubectl get pod ready-if-service-ready -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
[[ "$ready" == "True" ]] && pass_task "ready" "ready-if-service-ready is Ready" || fail_task "ready" "ready-if-service-ready is Ready"


print_summary "b04"
