#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pod pod-on-controlplane &>/dev/null && pass_task "pod" "Pod pod-on-controlplane exists" || fail_task "pod" "Pod pod-on-controlplane exists"
node=$(kubectl get pod pod-on-controlplane -o jsonpath='{.spec.nodeName}' 2>/dev/null)
controlplane=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
echo "$controlplane" | grep -q "$node" && pass_task "node" "Pod scheduled on control-plane" || fail_task "node" "Pod scheduled on control-plane"


print_summary "b12"
