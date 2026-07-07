#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

# Task 1: PVC created with correct spec
if kubectl get pvc mariadb -n mariadb &>/dev/null; then
  access=$(jsonpath pvc mariadb mariadb '{.spec.accessModes[0]}')
  storage=$(jsonpath pvc mariadb mariadb '{.spec.resources.requests.storage}')
  storage_normalized="${storage// /}"
  if [[ "$access" == "ReadWriteOnce" ]] && [[ "$storage_normalized" == "250Mi" || "$storage_normalized" == "250M" ]]; then
    pass_task "pvc-created" "PVC mariadb exists in mariadb namespace (ReadWriteOnce, 250Mi)"
  else
    fail_task "pvc-created" "PVC mariadb exists in mariadb namespace (ReadWriteOnce, 250Mi)" \
      "Expected ReadWriteOnce and 250Mi, got access=$access storage=$storage"
  fi
else
  fail_task "pvc-created" "PVC mariadb exists in mariadb namespace (ReadWriteOnce, 250Mi)" \
    "Run: kubectl get pvc -n mariadb"
fi

# Task 2: Deployment manifest or live deployment references PVC
manifest=""
for candidate in "${HOME}/mariadb-deploy.yaml" "/root/mariadb-deploy.yaml"; do
  if [[ -f "$candidate" ]]; then
    manifest="$candidate"
    break
  fi
done

live_claim=$(kubectl get deployment mariadb -n mariadb -o jsonpath='{.spec.template.spec.volumes[?(@.persistentVolumeClaim)].persistentVolumeClaim.claimName}' 2>/dev/null || true)

manifest_ok=false
if [[ -n "$manifest" ]] && grep -qE 'claimName:[[:space:]]*"?mariadb"?[[:space:]]*$' "$manifest"; then
  manifest_ok=true
fi

if $manifest_ok || [[ "$live_claim" == "mariadb" ]]; then
  pass_task "deployment-uses-pvc" "Deployment manifest references PVC claimName mariadb"
else
  fail_task "deployment-uses-pvc" "Deployment manifest references PVC claimName mariadb" \
    "Edit ~/mariadb-deploy.yaml (or /root/mariadb-deploy.yaml) and set claimName: mariadb"
fi

# Task 3: Deployment applied
if kubectl get deployment mariadb -n mariadb &>/dev/null; then
  pass_task "deployment-applied" "MariaDB deployment is applied to the cluster"
else
  fail_task "deployment-applied" "MariaDB deployment is applied to the cluster" \
    "Run: kubectl apply -f ~/mariadb-deploy.yaml"
fi

# Task 4: Deployment stable
ready_replicas=$(kubectl get deployment mariadb -n mariadb -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
available_replicas=$(kubectl get deployment mariadb -n mariadb -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
desired_replicas=$(kubectl get deployment mariadb -n mariadb -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")

if [[ "$ready_replicas" == "$desired_replicas" && "$available_replicas" == "$desired_replicas" && "$ready_replicas" != "0" ]]; then
  pass_task "deployment-stable" "MariaDB deployment is running and stable"
elif kubectl wait --for=condition=Available deployment/mariadb -n mariadb --timeout=10s &>/dev/null; then
  pass_task "deployment-stable" "MariaDB deployment is running and stable"
else
  fail_task "deployment-stable" "MariaDB deployment is running and stable" \
    "Check: kubectl get pods -n mariadb && kubectl describe deployment mariadb -n mariadb"
fi

print_summary "q01"
