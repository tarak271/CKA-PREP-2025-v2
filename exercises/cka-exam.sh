#!/bin/bash
set -euo pipefail

EXERCISES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$EXERCISES_DIR/.." && pwd)"
source "$EXERCISES_DIR/lib/common.sh"
source "$EXERCISES_DIR/lib/questions.sh"

EXAM_DURATION=7200  # 2 hours
STATE_DIR="${HOME}/.cka-exam"
STATE_FILE="$STATE_DIR/state.env"
SCORES_FILE="$STATE_DIR/scores.tsv"

# Question order: Etcd-Fix (q15) is LAST because it breaks the API server during setup.
QUESTION_ORDER=(
  "q01:Question-1 MariaDB-Persistent volume:MariaDB Persistent Volume Recovery"
  "q02:Question-2 ArgoCD:Install Argo CD with Helm (no CRDs)"
  "q03:Question-3 Sidecar:Add Sidecar Container to WordPress"
  "q04:Question-4 Resource-Allocation:WordPress Resource Allocation"
  "q05:Question-5 HPA:Horizontal Pod Autoscaler"
  "q06:Question-6 CRDs:cert-manager CRDs and Documentation"
  "q07:Question-7 PriorityClass:Priority Class"
  "q08:Question-8 CNI & Network Policy:Install CNI with Network Policy Support"
  "q09:Question-9 Cri-Dockerd:Install and Configure cri-dockerd"
  "q10:Question-10 Taints-Tolerations:Taints and Tolerations"
  "q11:Question-11 Gateway-API:Migrate Ingress to Gateway API"
  "q12:Question-12 Ingress:Ingress and NodePort Service"
  "q13:Question-13 Network-Policy:Least Permissive Network Policy"
  "q14:Question-14 Storage-Class:StorageClass Configuration"
  "q16:Question-16 NodePort:NodePort Service"
  "q17:Question-17 TLS-Config:TLS 1.3 Configuration"
  "q15:Question-15 Etcd-Fix:Fix kube-apiserver etcd Endpoint"
)

TOTAL_QUESTIONS=${#QUESTION_ORDER[@]}
TOTAL_MARKS=51

banner() {
  echo -e "${CYAN}${BOLD}"
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║           CKA Practice Exam — 2 Hour Timed Test              ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

usage() {
  banner
  cat <<EOF
Usage: exercises/cka-exam.sh <command>

Commands:
  start     Begin the 2-hour exam (runs lab setup for question 1)
  status    Show remaining time, current question, and score
  check     Validate the current question (1 mark per sub-task)
  next      Move to the next question (runs its lab setup)
  skip      Skip to next question without checking
  finish    End exam early and show final score
  reset     Clear exam state and start fresh

Environment:
  Run on Ubuntu with Kubernetes installed (kubectl configured).
  Clone this repo and execute from the repository root.

During the exam:
  1. Read the question and complete the tasks on your cluster.
  2. Run: exercises/cka-exam.sh check
  3. When satisfied, run: exercises/cka-exam.sh next
  4. Repeat until all ${TOTAL_QUESTIONS} questions are done or time expires.

Scoring: ${TOTAL_MARKS} marks total (1 mark per sub-task).

EOF
}

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$STATE_FILE"
  fi
}

save_state() {
  mkdir -p "$STATE_DIR"
  cat > "$STATE_FILE" <<EOF
EXAM_START=${EXAM_START:-0}
CURRENT_INDEX=${CURRENT_INDEX:-0}
EXAM_ACTIVE=${EXAM_ACTIVE:-0}
EXAM_FINISHED=${EXAM_FINISHED:-0}
EOF
}

remaining_seconds() {
  if [[ -z "${EXAM_START:-}" || "$EXAM_START" -eq 0 ]]; then
    echo "$EXAM_DURATION"
    return
  fi
  local now elapsed remaining
  now=$(date +%s)
  elapsed=$((now - EXAM_START))
  remaining=$((EXAM_DURATION - elapsed))
  [[ $remaining -lt 0 ]] && remaining=0
  echo "$remaining"
}

format_time() {
  local secs=$1
  printf '%02d:%02d:%02d' $((secs/3600)) $(((secs%3600)/60)) $((secs%60))
}

time_expired() {
  [[ $(remaining_seconds) -eq 0 ]]
}

check_prerequisites() {
  local errors=0
  echo "Checking prerequisites..."

  if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "  ${YELLOW}⚠${NC} Not running on Linux (exam is designed for Ubuntu)"
  else
    echo -e "  ${GREEN}✓${NC} Linux detected"
  fi

  if command -v kubectl &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} kubectl found"
  else
    echo -e "  ${RED}✗${NC} kubectl not found"
    errors=$((errors + 1))
  fi

  if kubectl cluster-info &>/dev/null 2>&1 || kubectl get nodes &>/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Kubernetes cluster reachable"
  else
    echo -e "  ${YELLOW}⚠${NC} Kubernetes cluster not reachable (some questions may still work)"
  fi

  if command -v python3 &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} python3 found"
  else
    echo -e "  ${RED}✗${NC} python3 required for validators"
    errors=$((errors + 1))
  fi

  [[ $errors -eq 0 ]]
}

parse_question() {
  local idx=$1
  local entry="${QUESTION_ORDER[$idx]}"
  IFS=':' read -r QID QDIR QTITLE <<< "$entry"
}

show_timer() {
  local remaining
  remaining=$(remaining_seconds)
  echo -e "${BOLD}Time remaining:${NC} $(format_time "$remaining")"
  if time_expired; then
    echo -e "${RED}Time is up! Submit with: exercises/cka-exam.sh finish${NC}"
  fi
}

show_score_summary() {
  local earned=0 possible=0
  if [[ -f "$SCORES_FILE" ]]; then
    while IFS=$'\t' read -r qid task_id status mark; do
      possible=$((possible + 1))
      earned=$((earned + mark))
    done < "$SCORES_FILE"
  fi
  echo -e "${BOLD}Score:${NC} ${earned}/${possible} marks"
  if [[ $possible -gt 0 ]]; then
    local pct=$((earned * 100 / possible))
    echo -e "${BOLD}Percentage:${NC} ${pct}%"
  fi
}

run_lab_setup() {
  local qdir="$1"
  local setup="$REPO_ROOT/$qdir/LabSetUp.bash"
  if [[ ! -f "$setup" ]]; then
    echo "Missing lab setup: $setup" >&2
    return 1
  fi
  chmod +x "$setup"
  echo -e "${CYAN}==> Running lab setup for ${qdir}${NC}"
  set +e
  "$setup"
  local rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo -e "${YELLOW}Lab setup exited with code $rc (you may still attempt the question)${NC}"
  fi
}

show_question() {
  local qdir="$1" qtitle="$2" qnum="$3"
  local questions_file="$REPO_ROOT/$qdir/Questions.bash"
  echo
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Question ${qnum}/${TOTAL_QUESTIONS}: ${qtitle}${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  show_timer
  echo
  if [[ -f "$questions_file" ]]; then
    cat "$questions_file"
  else
    echo "Question file not found: $questions_file"
  fi
  echo
  echo -e "${YELLOW}When done, check your work:${NC}  exercises/cka-exam.sh check"
  echo -e "${YELLOW}Move to next question:${NC}     exercises/cka-exam.sh next"
}

cmd_start() {
  banner
  if ! check_prerequisites; then
    echo -e "${RED}Prerequisites not met. Fix the issues above and retry.${NC}"
    exit 1
  fi

  load_state
  if [[ "${EXAM_ACTIVE:-0}" -eq 1 && "${EXAM_FINISHED:-0}" -eq 0 ]]; then
    echo "Exam already in progress. Use 'status' to see progress or 'reset' to start over."
    exit 1
  fi

  EXAM_START=$(date +%s)
  CURRENT_INDEX=0
  EXAM_ACTIVE=1
  EXAM_FINISHED=0
  save_state
  : > "$SCORES_FILE"

  parse_question 0
  echo -e "${GREEN}Exam started!${NC} You have $(format_time $EXAM_DURATION)."
  echo "Total questions: $TOTAL_QUESTIONS | Total marks: $TOTAL_MARKS"
  echo

  run_lab_setup "$QDIR"
  show_question "$QDIR" "$QTITLE" 1
}

cmd_status() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi

  banner
  parse_question "${CURRENT_INDEX:-0}"
  local qnum=$((CURRENT_INDEX + 1))
  echo -e "${BOLD}Current question:${NC} ${qnum}/${TOTAL_QUESTIONS} — ${QTITLE} (${QID})"
  show_timer
  show_score_summary
  echo
  if [[ "${EXAM_FINISHED:-0}" -eq 1 ]]; then
    echo "Exam finished."
  fi
}

cmd_check() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
  if time_expired; then
    echo -e "${RED}Time has expired.${NC}"
    cmd_finish
    exit 0
  fi

  parse_question "${CURRENT_INDEX:-0}"
  echo -e "${BOLD}Checking question ${QID}...${NC}"
  echo
  "$EXERCISES_DIR/validate.sh" "$QID" --record "$SCORES_FILE" || true
  echo
  show_score_summary
}

cmd_next() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
  if time_expired; then
    echo -e "${RED}Time has expired.${NC}"
    cmd_finish
    exit 0
  fi

  local next_index=$((CURRENT_INDEX + 1))
  if [[ $next_index -ge $TOTAL_QUESTIONS ]]; then
    echo "All questions completed!"
    cmd_finish
    return
  fi

  CURRENT_INDEX=$next_index
  save_state

  parse_question "$CURRENT_INDEX"
  local qnum=$((CURRENT_INDEX + 1))

  run_lab_setup "$QDIR"
  show_question "$QDIR" "$QTITLE" "$qnum"
}

cmd_skip() {
  echo -e "${YELLOW}Skipping check for current question.${NC}"
  cmd_next
}

cmd_finish() {
  load_state
  EXAM_FINISHED=1
  EXAM_ACTIVE=0
  save_state

  banner
  echo -e "${BOLD}══════ FINAL EXAM RESULTS ══════${NC}"
  echo

  local end_time
  end_time=$(date +%s)
  if [[ -n "${EXAM_START:-}" && "$EXAM_START" -gt 0 ]]; then
    local elapsed=$((end_time - EXAM_START))
    echo -e "${BOLD}Time used:${NC} $(format_time "$elapsed") / $(format_time $EXAM_DURATION)"
  fi

  echo
  show_score_summary
  echo

  if [[ -f "$SCORES_FILE" ]]; then
    echo -e "${BOLD}Breakdown by question:${NC}"
    echo "────────────────────────────────────────"
    local current_qid=""
    local q_earned=0 q_total=0
    while IFS=$'\t' read -r qid task_id status mark; do
      if [[ -n "$current_qid" && "$qid" != "$current_qid" ]]; then
        printf "  %-6s %2d/%2d\n" "$current_qid" "$q_earned" "$q_total"
        q_earned=0
        q_total=0
      fi
      current_qid="$qid"
      q_total=$((q_total + 1))
      q_earned=$((q_earned + mark))
    done < "$SCORES_FILE"
    if [[ -n "$current_qid" ]]; then
      printf "  %-6s %2d/%2d\n" "$current_qid" "$q_earned" "$q_total"
    fi
    echo
    echo -e "${BOLD}Unattempted questions:${NC}"
    local attempted=""
    attempted=$(cut -f1 "$SCORES_FILE" | sort -u)
    for entry in "${QUESTION_ORDER[@]}"; do
      IFS=':' read -r qid _ _ <<< "$entry"
      if ! echo "$attempted" | grep -qx "$qid"; then
        echo "  $qid (not checked)"
      fi
    done
  else
    echo "No questions were checked. Run 'check' after completing each task."
  fi

  echo
  echo -e "${GREEN}Exam complete.${NC} State saved in $STATE_DIR"
}

cmd_reset() {
  rm -rf "$STATE_DIR"
  echo "Exam state cleared. Run 'exercises/cka-exam.sh start' to begin a new exam."
}

# Main
COMMAND="${1:-}"
case "$COMMAND" in
  start)  cmd_start ;;
  status) cmd_status ;;
  check)  cmd_check ;;
  next)   cmd_next ;;
  skip)   cmd_skip ;;
  finish) cmd_finish ;;
  reset)  cmd_reset ;;
  -h|--help|help|"") usage ;;
  *)
    echo "Unknown command: $COMMAND" >&2
    usage
    exit 1
    ;;
esac
