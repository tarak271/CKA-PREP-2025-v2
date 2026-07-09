#!/bin/bash
set -euo pipefail
KILLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKS_DIR="$KILLER_DIR/checks/set-b"

declare -A QUESTION_CHECKS=(
  [b01]="b01.sh"
  [b02]="b02.sh"
  [b03]="b03.sh"
  [b04]="b04.sh"
  [b05]="b05.sh"
  [b06]="b06.sh"
  [b07]="b07.sh"
  [b08]="b08.sh"
  [b09]="b09.sh"
  [b10]="b10.sh"
  [b11]="b11.sh"
  [b12]="b12.sh"
  [b13]="b13.sh"
  [b14]="b14.sh"
  [b15]="b15.sh"
  [b16]="b16.sh"
  [b17]="b17.sh"
)

declare -A DIR_TO_ID=(
  ["Question-01-DNS-FQDN-Headless-Service"]="b01"
  ["Question-02-Create-a-Static-Pod-and-Service"]="b02"
  ["Question-03-Kubelet-client-server-cert-info"]="b03"
  ["Question-04-Pod-Ready-if-Service-is-reachable"]="b04"
  ["Question-05-Kubectl-sorting"]="b05"
  ["Question-06-Fix-Kubelet"]="b06"
  ["Question-07-Etcd-Operations"]="b07"
  ["Question-08-Get-Controlplane-Information"]="b08"
  ["Question-09-Kill-Scheduler-Manual-Scheduling"]="b09"
  ["Question-10-PV-PVC-Dynamic-Provisioning"]="b10"
  ["Question-11-Create-Secret-and-mount-into-Pod"]="b11"
  ["Question-12-Schedule-Pod-on-Controlplane-Nodes"]="b12"
  ["Question-13-Multi-Containers-and-Pod-shared-Volume"]="b13"
  ["Question-14-Find-out-Cluster-Information"]="b14"
  ["Question-15-Cluster-Event-Logging"]="b15"
  ["Question-16-Namespaces-and-Api-Resources"]="b16"
  ["Question-17-Operator-CRDs-RBAC-Kustomize"]="b17"
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
