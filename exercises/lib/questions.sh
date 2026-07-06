#!/bin/bash
# Map question IDs to validation check scripts.
set -euo pipefail

EXERCISES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_DIR="$EXERCISES_DIR/checks"

declare -A QUESTION_CHECKS=(
  [q01]="q01-mariadb.sh"
  [q02]="q02-argocd.sh"
  [q03]="q03-sidecar.sh"
  [q04]="q04-resources.sh"
  [q05]="q05-hpa.sh"
  [q06]="q06-crds.sh"
  [q07]="q07-priority.sh"
  [q08]="q08-cni.sh"
  [q09]="q09-cri-dockerd.sh"
  [q10]="q10-taints.sh"
  [q11]="q11-gateway.sh"
  [q12]="q12-ingress.sh"
  [q13]="q13-network-policy.sh"
  [q14]="q14-storage.sh"
  [q15]="q15-etcd.sh"
  [q16]="q16-nodeport.sh"
  [q17]="q17-tls.sh"
)

declare -A DIR_TO_ID=(
  ["Question-1 MariaDB-Persistent volume"]="q01"
  ["Question-2 ArgoCD"]="q02"
  ["Question-3 Sidecar"]="q03"
  ["Question-4 Resource-Allocation"]="q04"
  ["Question-5 HPA"]="q05"
  ["Question-6 CRDs"]="q06"
  ["Question-7 PriorityClass"]="q07"
  ["Question-8 CNI & Network Policy"]="q08"
  ["Question-9 Cri-Dockerd"]="q09"
  ["Question-10 Taints-Tolerations"]="q10"
  ["Question-11 Gateway-API"]="q11"
  ["Question-12 Ingress"]="q12"
  ["Question-13 Network-Policy"]="q13"
  ["Question-14 Storage-Class"]="q14"
  ["Question-15 Etcd-Fix"]="q15"
  ["Question-16 NodePort"]="q16"
  ["Question-17 TLS-Config"]="q17"
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
  if [[ -z "$script" ]]; then
    return 1
  fi
  echo "$CHECKS_DIR/$script"
}
