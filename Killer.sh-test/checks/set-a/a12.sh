#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n project-tiger get deployment deploy-important &>/dev/null &&           pass_task "deploy" "Deployment deploy-important exists in project-tiger" ||           fail_task "deploy" "Deployment deploy-important exists in project-tiger"
replicas=$(kubectl -n project-tiger get deployment deploy-important -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
[[ "$replicas" == "3" ]] && pass_task "replicas" "Deployment has 3 replicas" ||           fail_task "replicas" "Deployment has 3 replicas"
label=$(kubectl -n project-tiger get deployment deploy-important -o jsonpath='{.spec.template.metadata.labels.id}' 2>/dev/null)
[[ "$label" == "very-important" ]] && pass_task "label" "Pods labeled id=very-important" ||           fail_task "label" "Pods labeled id=very-important"
cnt=$(kubectl -n project-tiger get deployment deploy-important -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
[[ "$cnt" -ge 2 ]] && pass_task "containers" "Deployment has container1 and container2" ||           fail_task "containers" "Deployment has container1 and container2"


print_summary "a12"
