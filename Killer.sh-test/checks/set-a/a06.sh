#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pv safari-pv &>/dev/null && pass_task "pv" "PV safari-pv created" || fail_task "pv" "PV safari-pv created"
phase=$(kubectl -n project-t230 get pvc safari-pvc -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
[[ "$phase" == "Bound" ]] && pass_task "pvc" "PVC safari-pvc bound" || fail_task "pvc" "PVC safari-pvc bound"
kubectl -n project-t230 get deploy safari &>/dev/null && pass_task "deploy" "Deployment safari created" || fail_task "deploy" "Deployment safari created"
mount=$(kubectl -n project-t230 get deploy safari -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/safari-data")].mountPath}' 2>/dev/null)
[[ "$mount" == "/tmp/safari-data" ]] && pass_task "mount" "Volume mounted at /tmp/safari-data" || fail_task "mount" "Volume mounted at /tmp/safari-data"


print_summary "a06"
