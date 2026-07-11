#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n secret get secret secret1 &>/dev/null && pass_task "secret1" "Secret secret1 in namespace secret" ||           fail_task "secret1" "Secret secret1 in namespace secret"
kubectl -n secret get secret secret2 &>/dev/null && pass_task "secret2" "Secret secret2 in namespace secret" ||           fail_task "secret2" "Secret secret2 in namespace secret"
mount=$(kubectl -n secret get pod secret-pod -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/secret1")].mountPath}' 2>/dev/null)
[[ "$mount" == "/tmp/secret1" ]] && pass_task "mount" "secret1 mounted at /tmp/secret1" ||           fail_task "mount" "secret1 mounted at /tmp/secret1"
env=$(kubectl -n secret get pod secret-pod -o jsonpath='{.spec.containers[0].envFrom}' 2>/dev/null)
echo "$env" | grep -q secret2 && pass_task "env" "secret2 exposed as env vars" ||           fail_task "env" "secret2 exposed as env vars"


print_summary "b11"
