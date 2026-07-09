#!/bin/bash
set -euo pipefail
KILLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKS_DIR="$KILLER_DIR/checks/set-a"

declare -A QUESTION_CHECKS=(
  [a01]="a01.sh"
  [a02]="a02.sh"
  [a03]="a03.sh"
  [a04]="a04.sh"
  [a05]="a05.sh"
  [a06]="a06.sh"
  [a07]="a07.sh"
  [a08]="a08.sh"
  [a09]="a09.sh"
  [a10]="a10.sh"
  [a11]="a11.sh"
  [a12]="a12.sh"
  [a13]="a13.sh"
  [a14]="a14.sh"
  [a15]="a15.sh"
  [a16]="a16.sh"
  [a17]="a17.sh"
)

declare -A DIR_TO_ID=(
  ["Question-01-Contexts"]="a01"
  ["Question-02-MinIO-Operator-CRD-Config-Helm-Install"]="a02"
  ["Question-03-Scale-down-StatefulSet"]="a03"
  ["Question-04-Find-Pods-first-to-be-terminated"]="a04"
  ["Question-05-Kustomize-configure-HPA-Autoscaler"]="a05"
  ["Question-06-Storage-PV-PVC-Pod-volume"]="a06"
  ["Question-07-Node-and-Pod-Resource-Usage"]="a07"
  ["Question-08-Update-Kubernetes-Version-and-join-cluster"]="a08"
  ["Question-09-Contact-K8s-Api-from-inside-Pod"]="a09"
  ["Question-10-RBAC-ServiceAccount-Role-RoleBinding"]="a10"
  ["Question-11-DaemonSet-on-all-Nodes"]="a11"
  ["Question-12-Deployment-on-all-Nodes"]="a12"
  ["Question-13-Gateway-Api-Ingress"]="a13"
  ["Question-14-Check-how-long-certificates-are-valid"]="a14"
  ["Question-15-NetworkPolicy"]="a15"
  ["Question-16-Update-CoreDNS-Configuration"]="a16"
  ["Question-17-Find-Container-of-Pod-and-check-info"]="a17"
)


resolve_question_id() {
  local input="$1"
  if [[ -n "${QUESTION_CHECKS[$input]:-}" ]]; then
    echo "$input"
    return
  fi
  if [[ -n "${DIR_TO_ID[$input]:-}" ]]; then
    echo "${DIR_TO_ID[$input]}"
    return
  fi
  echo ""
}

get_check_script() {
  local qid="$1"
  local script="${QUESTION_CHECKS[$qid]:-}"
  [[ -z "$script" ]] && return 1
  echo "$CHECKS_DIR/$script"
}
