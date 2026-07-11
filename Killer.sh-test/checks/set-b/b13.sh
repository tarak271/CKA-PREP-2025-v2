#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pod multi-container-playground &>/dev/null && pass_task "pod" "Pod multi-container-playground exists" ||           fail_task "pod" "Pod multi-container-playground exists"
cnt=$(kubectl get pod multi-container-playground -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
[[ "$cnt" -ge 2 ]] && pass_task "containers" "Pod has multiple containers" ||           fail_task "containers" "Pod has multiple containers"
vol=$(kubectl get pod multi-container-playground -o jsonpath='{.spec.volumes[0].name}' 2>/dev/null)
[[ -n "$vol" ]] && pass_task "volume" "Shared volume configured" ||           fail_task "volume" "Shared volume configured"


print_summary "b13"
