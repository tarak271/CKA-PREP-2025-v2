#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n operator-prod get deploy &>/dev/null && pass_task "operator" "Operator deployed in operator-prod" || fail_task "operator" "Operator deployed in operator-prod"
kubectl get crd students.education.killer.sh &>/dev/null 2>&1 && pass_task "crd" "Student CRD present" ||           fail_task "crd" "Student CRD present" "kubectl get crd students.education.killer.sh"


print_summary "b17"
