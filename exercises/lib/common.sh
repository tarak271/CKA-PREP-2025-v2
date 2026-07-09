#!/bin/bash
# Shared helpers for CKA exam validators.

if [[ -z "${CKA_EXAM_LIB_LOADED:-}" ]]; then
  CKA_EXAM_LIB_LOADED=1

  PASS=0
  FAIL=0
  TOTAL=0
  RESULTS=()

  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  DIM='\033[2m'
  BOLD='\033[1m'
  NC='\033[0m'

  pass_task() {
    local id="$1"
    local description="$2"
    PASS=$((PASS + 1))
    TOTAL=$((TOTAL + 1))
    RESULTS+=("PASS|$id|$description")
    echo -e "  ${GREEN}✓${NC} $description"
  }

  fail_task() {
    local id="$1"
    local description="$2"
    local hint="${3:-}"
    FAIL=$((FAIL + 1))
    TOTAL=$((TOTAL + 1))
    RESULTS+=("FAIL|$id|$description")
    echo -e "  ${RED}✗${NC} $description"
    if [[ -n "$hint" ]]; then
      echo -e "    ${YELLOW}Hint:${NC} $hint"
    fi
  }

  reset_results() {
    PASS=0
    FAIL=0
    TOTAL=0
    RESULTS=()
  }

  print_summary() {
    local question_id="${1:-}"
    echo
    echo -e "${BOLD}Score for ${question_id}:${NC} ${PASS}/${TOTAL} (${PASS} mark(s) this question)"
    echo -e "${DIM}Overall exam score: run exercises/cka-exam.sh status or finish${NC}"
    if [[ $FAIL -gt 0 ]]; then
      echo -e "${YELLOW}${FAIL} sub-task(s) still need attention.${NC}"
    fi
  }

  kubectl_resource_exists() {
    kubectl get "$1" "$2" -n "${3:-}" &>/dev/null
  }

  jsonpath() {
    kubectl get "$1" "$2" -n "${3:-}" -o "jsonpath=$4" 2>/dev/null
  }

  node_name() {
    kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
  }

  normalize_cpu() {
    local value="$1"
    if [[ "$value" =~ m$ ]]; then
      echo "${value%m}"
    elif [[ "$value" =~ ^[0-9]+$ ]]; then
      echo $((value * 1000))
    else
      echo "$value"
    fi
  }

  normalize_memory() {
    local value="$1"
    case "$value" in
      *Gi) echo "${value%Gi}000" ;;
      *Mi) echo "${value%Mi}" ;;
      *Ki) echo "$(( ${value%Ki} / 1024 ))" ;;
      *) echo "$value" ;;
    esac
  }

  export_results_tsv() {
    local question_id="$1"
    local outfile="$2"
    for entry in "${RESULTS[@]}"; do
      IFS='|' read -r status task_id description <<< "$entry"
      local mark=0
      [[ "$status" == "PASS" ]] && mark=1
      printf '%s\t%s\t%s\t%d\n' "$question_id" "$task_id" "$status" "$mark" >> "$outfile"
    done
  }

  require_kubectl() {
    if ! command -v kubectl &>/dev/null; then
      echo "kubectl is required but not installed." >&2
      exit 1
    fi
  }

  require_root_for_file() {
    local path="$1"
    if [[ ! -r "$path" ]] && [[ "$(id -u)" -ne 0 ]]; then
      return 1
    fi
    return 0
  }
fi
