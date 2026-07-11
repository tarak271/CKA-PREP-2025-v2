#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-tiger get daemonset ds-important &>/dev/null &&           pass_task "ds" "DaemonSet ds-important exists in project-tiger" ||           fail_task "ds" "DaemonSet ds-important exists in project-tiger"
img=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[[ "$img" == "httpd:2-alpine" ]] && pass_task "image" "Uses image httpd:2-alpine" ||           fail_task "image" "Uses image httpd:2-alpine" "Current image: $img"
cpu=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
mem=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
[[ "$cpu" == "10m" && "$mem" == "10Mi" ]] && pass_task "resources" "Pods request 10m CPU and 10Mi memory" ||           fail_task "resources" "Pods request 10m CPU and 10Mi memory"
tol=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.tolerations[*].key}' 2>/dev/null)
echo "$tol" | grep -qE 'node-role.kubernetes.io/(control-plane|master)' &&           pass_task "toleration" "Tolerates control-plane taint" ||           fail_task "toleration" "Tolerates control-plane taint"             "Add toleration for node-role.kubernetes.io/control-plane:NoSchedule"
nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
ready=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.status.numberReady}' 2>/dev/null || echo 0)
[[ "$nodes" -gt 0 && "$ready" -eq "$nodes" ]] && pass_task "all-nodes" "DaemonSet pod on every node ($ready/$nodes)" ||           fail_task "all-nodes" "DaemonSet pod on every node ($ready/$nodes)"


print_summary "a11"
