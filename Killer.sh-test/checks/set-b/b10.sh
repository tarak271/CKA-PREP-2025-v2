#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get storageclass &>/dev/null && pass_task "sc" "StorageClass created" || fail_task "sc" "StorageClass created"
kubectl -n project-bern get pvc &>/dev/null && pass_task "pvc" "Job uses PVC" || fail_task "pvc" "Job uses PVC"
kubectl -n project-bern get job backup &>/dev/null && pass_task "job" "Backup job applied" || fail_task "job" "Backup job applied"


print_summary "b10"
