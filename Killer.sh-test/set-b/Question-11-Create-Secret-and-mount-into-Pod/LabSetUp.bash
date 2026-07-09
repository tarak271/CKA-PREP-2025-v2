#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 11)
cat > "$DIR/secret1.yaml" <<'YAML'
apiVersion: v1
kind: Secret
metadata:
  name: secret1
type: Opaque
data:
  key1: dmFsdWUx
YAML
kubectl delete pod secret-pod --ignore-not-found

