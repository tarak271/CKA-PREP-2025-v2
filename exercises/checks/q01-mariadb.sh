#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: PVC created with correct spec
if kubectl get pvc mariadb -n mariadb &>/dev/null; then
  access=$(jsonpath pvc mariadb mariadb '{.spec.accessModes[0]}')
  storage=$(jsonpath pvc mariadb mariadb '{.spec.resources.requests.storage}')
  if [[ "$access" == "ReadWriteOnce" ]] && [[ "$storage" == "250Mi" || "$storage" == "250M" ]]; then
    pass_task "pvc-created" "PVC mariadb exists in mariadb namespace (ReadWriteOnce, 250Mi)"
  else
    fail_task "pvc-created" "PVC mariadb exists in mariadb namespace (ReadWriteOnce, 250Mi)" \
      "Expected ReadWriteOnce and 250Mi, got access=$access storage=$storage"
  fi
else
  fail_task "pvc-created" "PVC mariadb exists in mariadb namespace (ReadWriteOnce, 250Mi)" \
    "Run: kubectl get pvc -n mariadb"
fi

# Task 2: Deployment manifest references PVC
manifest="${HOME}/mariadb-deploy.yaml"
if [[ -f "$manifest" ]] && grep -q 'claimName: mariadb' "$manifest"; then
  pass_task "deployment-uses-pvc" "Deployment manifest references PVC claimName mariadb"
else
  fail_task "deployment-uses-pvc" "Deployment manifest references PVC claimName mariadb" \
    "Edit ~/mariadb-deploy.yaml and set claimName: mariadb"
fi

# Task 3: Deployment applied
if kubectl get deployment mariadb -n mariadb &>/dev/null; then
  pass_task "deployment-applied" "MariaDB deployment is applied to the cluster"
else
  fail_task "deployment-applied" "MariaDB deployment is applied to the cluster" \
    "Run: kubectl apply -f ~/mariadb-deploy.yaml"
fi

# Task 4: Deployment stable
if kubectl get deployment mariadb -n mariadb -o jsonpath='{.status.availableReplicas}' 2>/dev/null | grep -q '^1$'; then
  pass_task "deployment-stable" "MariaDB deployment is running and stable"
elif kubectl wait --for=condition=Available deployment/mariadb -n mariadb --timeout=5s &>/dev/null; then
  pass_task "deployment-stable" "MariaDB deployment is running and stable"
else
  fail_task "deployment-stable" "MariaDB deployment is running and stable" \
    "Check: kubectl get pods -n mariadb && kubectl describe deployment mariadb -n mariadb"
fi

print_summary "q01"
[[ $FAIL -eq 0 ]]
