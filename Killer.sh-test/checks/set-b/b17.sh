#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n operator-prod get deploy &>/dev/null && pass_task "operator" "Operator deployed in operator-prod" || fail_task "operator" "Operator deployed in operator-prod"
kubectl get crd students.example.com &>/dev/null 2>&1 || kubectl -n operator-prod get pods &>/dev/null && pass_task "crd" "CRDs/operator resources present" || fail_task "crd" "CRDs/operator resources present"


print_summary "b17"
