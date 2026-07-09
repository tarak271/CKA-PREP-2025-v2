#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get namespace minio &>/dev/null && pass_task "namespace" "Namespace minio exists" || fail_task "namespace" "Namespace minio exists"
helm list -n minio 2>/dev/null | grep -q minio-operator && pass_task "helm" "Helm release minio-operator installed" || fail_task "helm" "Helm release minio-operator installed" "helm -n minio install minio-operator minio/operator"
if grep -q "enableSFTP: true" "$(course_path 2)/minio-tenant.yaml" 2>/dev/null; then
  pass_task "sftp" "enableSFTP: true set in minio-tenant.yaml"
else
  fail_task "sftp" "enableSFTP: true set in minio-tenant.yaml"
fi
kubectl -n minio get tenant tenant &>/dev/null && pass_task "tenant" "Tenant resource created" || fail_task "tenant" "Tenant resource created" "kubectl -f $(course_path 2)/minio-tenant.yaml apply"


print_summary "a02"
