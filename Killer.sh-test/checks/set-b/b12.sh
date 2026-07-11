#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pod pod1 &>/dev/null && pass_task "pod" "Pod pod1 exists in default" ||           fail_task "pod" "Pod pod1 exists in default"
cname=$(kubectl get pod pod1 -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
[[ "$cname" == "pod1-container" ]] && pass_task "container" "Container named pod1-container" ||           fail_task "container" "Container named pod1-container"
node=$(kubectl get pod pod1 -o jsonpath='{.spec.nodeName}' 2>/dev/null)
controlplane=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
echo "$controlplane" | grep -q "$node" && pass_task "node" "Pod scheduled on control-plane" ||           fail_task "node" "Pod scheduled on control-plane"


print_summary "b12"
