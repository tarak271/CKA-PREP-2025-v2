#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl -n api-gateway-staging get deploy api-gateway &>/dev/null && pass_task "staging-deploy" "Staging deployment applied via kustomize" || fail_task "staging-deploy" "Staging deployment applied via kustomize"
kubectl -n api-gateway-prod get deploy api-gateway &>/dev/null && pass_task "prod-deploy" "Prod deployment applied via kustomize" || fail_task "prod-deploy" "Prod deployment applied via kustomize"
staging_hpa=$(kubectl -n api-gateway-staging get hpa -o name 2>/dev/null | wc -l | tr -d ' ')
prod_hpa=$(kubectl -n api-gateway-prod get hpa -o name 2>/dev/null | wc -l | tr -d ' ')
[[ "$staging_hpa" -ge 1 ]] && pass_task "staging-hpa" "HPA configured for staging" || fail_task "staging-hpa" "HPA configured for staging"
[[ "$prod_hpa" -ge 1 ]] && pass_task "prod-hpa" "HPA configured for prod" || fail_task "prod-hpa" "HPA configured for prod"


print_summary "a05"
