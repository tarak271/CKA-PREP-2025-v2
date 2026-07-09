#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 17)
rm -rf "$DIR/operator"
mkdir -p "$DIR/operator/base" "$DIR/operator/prod"
cat > "$DIR/operator/base/kustomization.yaml" <<'YAML'
resources:
  - crds.yaml
  - rbac.yaml
  - operator.yaml
YAML
cat > "$DIR/operator/prod/kustomization.yaml" <<'YAML'
namespace: operator-prod
resources:
  - ../base
YAML
kubectl delete namespace operator-prod --ignore-not-found --wait=false
echo "Kustomize operator config at $DIR/operator"

