#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-hamster get serviceaccount processor &>/dev/null &&           pass_task "sa" "ServiceAccount processor exists" ||           fail_task "sa" "ServiceAccount processor exists"
kubectl -n project-hamster get role processor &>/dev/null &&           pass_task "role" "Role processor exists" ||           fail_task "role" "Role processor exists"
kubectl -n project-hamster get rolebinding processor &>/dev/null &&           pass_task "binding" "RoleBinding processor exists" ||           fail_task "binding" "RoleBinding processor exists"
kubectl -n project-hamster auth can-i create secret           --as system:serviceaccount:project-hamster:processor 2>/dev/null | grep -q yes &&           pass_task "create-secret" "Can create secrets" ||           fail_task "create-secret" "Can create secrets"
kubectl -n project-hamster auth can-i create configmap           --as system:serviceaccount:project-hamster:processor 2>/dev/null | grep -q yes &&           pass_task "create-cm" "Can create configmaps" ||           fail_task "create-cm" "Can create configmaps"
kubectl -n project-hamster auth can-i create pod           --as system:serviceaccount:project-hamster:processor 2>/dev/null | grep -q no &&           pass_task "no-pod" "Cannot create pods" ||           fail_task "no-pod" "Cannot create pods"


print_summary "a10"
