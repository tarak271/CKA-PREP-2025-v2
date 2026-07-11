#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 9)
rm -f "$DIR/result.json"
kubectl create namespace project-swan --dry-run=client -o yaml | kubectl apply -f -

# Reset Q9 resources (student creates api-contact pod)
kubectl -n project-swan delete pod api-contact --ignore-not-found --wait=false
kubectl -n project-swan delete secret read-me --ignore-not-found
kubectl -n project-swan delete rolebinding secret-reader --ignore-not-found
kubectl -n project-swan delete role secret-reader --ignore-not-found
kubectl -n project-swan delete serviceaccount secret-reader --ignore-not-found
kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found
kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found

# ServiceAccount + RBAC (can list secrets via Kubernetes API)
kubectl -n project-swan create serviceaccount secret-reader
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: killer-a09-secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: killer-a09-secret-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: killer-a09-secret-reader
subjects:
- kind: ServiceAccount
  name: secret-reader
  namespace: project-swan
YAML

# Sample secret for the API response
kubectl -n project-swan create secret generic read-me --from-literal=token=exam-token

echo "Ready: namespace project-swan with ServiceAccount secret-reader"
echo "Create Pod api-contact (nginx:1-alpine) using serviceAccountName: secret-reader"

