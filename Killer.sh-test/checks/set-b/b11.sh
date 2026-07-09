#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get secret secret1 &>/dev/null && pass_task "secret" "Secret secret1 created" || fail_task "secret" "Secret secret1 created"
mount=$(kubectl get pod secret-pod -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/secret1")].mountPath}' 2>/dev/null)
[[ "$mount" == "/tmp/secret1" ]] && pass_task "mount" "Secret mounted at /tmp/secret1" || fail_task "mount" "Secret mounted at /tmp/secret1"


print_summary "b11"
