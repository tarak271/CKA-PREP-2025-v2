#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 10)
kubectl create namespace project-bern --dry-run=client -o yaml | kubectl apply -f -
cat > "$DIR/backup.yaml" <<'YAML'
apiVersion: batch/v1
kind: Job
metadata:
  name: backup
  namespace: project-bern
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: backup
        image: busybox:1.36
        command: ["sh", "-c", "echo backup; sleep 5"]
YAML
kubectl -n project-bern delete job backup --ignore-not-found

