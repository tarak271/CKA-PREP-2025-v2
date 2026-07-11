#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


systemctl is-active kubelet &>/dev/null && pass_task "kubelet" "Kubelet is running" || fail_task "kubelet" "Kubelet is running" "systemctl status kubelet"
kubectl get nodes &>/dev/null && pass_task "cluster" "Cluster API reachable" || fail_task "cluster" "Cluster API reachable"
kubectl get pod success -n default &>/dev/null && pass_task "success-pod" "Pod success exists in default" ||           fail_task "success-pod" "Pod success exists in default" "kubectl run success --image=nginx:1-alpine"


print_summary "b06"
