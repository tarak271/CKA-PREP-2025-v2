#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get pod -A 2>/dev/null | grep -q my-static && pass_task "static-pod" "Static pod running" || fail_task "static-pod" "Static pod running"
kubectl get svc static-pod-service &>/dev/null && pass_task "service" "NodePort service static-pod-service exists" || fail_task "service" "NodePort service static-pod-service exists"
ep=$(kubectl get endpointslices -l kubernetes.io/service-name=static-pod-service -o jsonpath='{.items[0].endpoints}' 2>/dev/null)
[[ -n "$ep" && "$ep" != "[]" ]] && pass_task "endpoint" "Service has endpoint" || fail_task "endpoint" "Service has endpoint"


print_summary "b02"
