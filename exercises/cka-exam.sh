#!/bin/bash
set -euo pipefail

EXERCISES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$EXERCISES_DIR/.." && pwd)"
source "$EXERCISES_DIR/lib/common.sh"
source "$EXERCISES_DIR/lib/questions.sh"
source "$EXERCISES_DIR/lib/timer.sh"
source "$EXERCISES_DIR/lib/cleanup.sh"
source "$EXERCISES_DIR/lib/cluster-reset.sh"
source "$EXERCISES_DIR/lib/scoring.sh"

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
TOTAL_MARKS=$(compute_total_exam_marks)

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
  timer     Show live countdown in this terminal (updates every second)
  pause     Pause the exam timer for a break
  resume    Resume the exam timer after a break
  status    Show remaining time, current question, and score
  check     Validate the current question (1 mark per sub-task)
  next      Move to the next question (runs its lab setup)
  prev      Go back to the previous question (re-runs its lab setup)
  skip      Skip to next question without checking
  finish    End exam early and show final score
  reset     Clear exam state and start fresh

Environment:
  Run on Ubuntu with Kubernetes installed (kubectl configured).
  Clone this repo and execute from the repository root.

During the exam:
  1. 'start' resets the cluster via exercises/reset.sh, then begins the timed exam.
  2. A live timer starts automatically and updates every second.
  2. Timer pauses while lab setup scripts run (setup time is excluded).
  3. Use 'pause' and 'resume' when you need a break (break time is excluded).
  4. Read the question and complete the tasks on your cluster.
  5. Run: exercises/cka-exam.sh check
  6. When satisfied, run: exercises/cka-exam.sh next
  7. Use: exercises/cka-exam.sh prev  to revisit the previous question

The live timer stays pinned to the **top line** without moving your cursor — command output scrolls normally below.

For a dedicated timer view in another terminal:
  bash exercises/cka-exam.sh timer

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
PAUSED_SECONDS=${PAUSED_SECONDS:-0}
SETUP_IN_PROGRESS=${SETUP_IN_PROGRESS:-0}
SETUP_PAUSE_START=${SETUP_PAUSE_START:-0}
BREAK_IN_PROGRESS=${BREAK_IN_PROGRESS:-0}
BREAK_PAUSE_START=${BREAK_PAUSE_START:-0}
EXAM_DURATION=${EXAM_DURATION:-7200}
TOTAL_QUESTIONS=${TOTAL_QUESTIONS:-17}
EOF
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

  if command -v kubeadm &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} kubeadm found"
  else
    echo -e "  ${RED}✗${NC} kubeadm not found (required for cluster reset at exam start)"
    errors=$((errors + 1))
  fi

  echo -e "  ${YELLOW}ℹ${NC} Cluster reset at start requires sudo (kubeadm, iptables, systemctl)"

  if kubectl cluster-info &>/dev/null 2>&1 || kubectl get nodes &>/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Kubernetes cluster reachable (will be reset at exam start)"
  else
    echo -e "  ${YELLOW}⚠${NC} Kubernetes cluster not reachable (reset will create a fresh cluster)"
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
  local remaining formatted pause_label
  remaining=$(remaining_seconds)
  formatted=$(format_time "$remaining")
  pause_label=$(timer_pause_label)
  if [[ -n "$pause_label" ]]; then
    echo -e "${BOLD}Time remaining:${NC} ${formatted} ${YELLOW}(${pause_label})${NC}"
  else
    echo -e "${BOLD}Time remaining:${NC} ${formatted}"
  fi
  if time_expired; then
    echo -e "${RED}Time is up! Submit with: exercises/cka-exam.sh finish${NC}"
  fi
}

ensure_exam_active() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
}

begin_command_output() {
  :
}

end_command_output() {
  :
}

run_exam_cluster_reset() {
  local reset_script="$EXERCISES_DIR/reset.sh"
  echo -e "${CYAN}==> Resetting Kubernetes cluster to a clean state${NC}"
  echo -e "${YELLOW}This runs exercises/reset.sh (kubeadm reset + fresh init).${NC}"
  echo -e "${YELLOW}The exam timer has not started yet — reset time is excluded.${NC}"
  echo

  set +e
  run_cluster_reset "$reset_script"
  local rc=$?
  set -e

  if [[ $rc -ne 0 ]]; then
    echo -e "${RED}Cluster reset failed. Fix the errors above and run: exercises/cka-exam.sh start${NC}" >&2
    return 1
  fi

  echo
  return 0
}

run_lab_setup() {
  local qdir="$1"
  local qid="$2"
  local setup="$REPO_ROOT/$qdir/LabSetUp.bash"
  if [[ ! -f "$setup" ]]; then
    echo "Missing lab setup: $setup" >&2
    return 1
  fi

  load_state
  timer_pause_for_setup
  save_state

  begin_command_output
  run_question_cleanup "$qid"

  chmod +x "$setup"
  echo -e "${CYAN}==> Running lab setup for ${qdir}${NC}"
  echo -e "${YELLOW}⏸  Exam timer paused during setup${NC}"

  set +e
  "$setup"
  local rc=$?
  set -e

  load_state
  timer_resume_after_setup
  save_state

  echo -e "${GREEN}▶  Exam timer resumed${NC}"
  if [[ $rc -ne 0 ]]; then
    echo -e "${YELLOW}Lab setup exited with code $rc (you may still attempt the question)${NC}"
  fi
  end_command_output
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
  echo -e "${YELLOW}Next question:${NC}              exercises/cka-exam.sh next"
  echo -e "${YELLOW}Previous question:${NC}          exercises/cka-exam.sh prev"
  echo -e "${YELLOW}Dedicated timer view:${NC}       exercises/cka-exam.sh timer  (2nd terminal)"
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

  stop_timer_daemon

  begin_command_output
  if ! run_exam_cluster_reset; then
    end_command_output
    exit 1
  fi
  end_command_output

  EXAM_START=$(date +%s)
  CURRENT_INDEX=0
  EXAM_ACTIVE=1
  EXAM_FINISHED=0
  PAUSED_SECONDS=0
  SETUP_IN_PROGRESS=0
  SETUP_PAUSE_START=0
  BREAK_IN_PROGRESS=0
  BREAK_PAUSE_START=0
  save_state
  : > "$SCORES_FILE"

  start_timer_daemon "$STATE_DIR" "$EXERCISES_DIR"

  parse_question 0
  echo
  echo -e "${GREEN}Exam started!${NC} You have $(format_time $EXAM_DURATION)."
  echo "Total questions: $TOTAL_QUESTIONS | Total marks: $TOTAL_MARKS"
  echo -e "${CYAN}Timer is pinned to the top line — output scrolls normally below.${NC}"
  echo -e "${CYAN}Tip: run 'bash exercises/cka-exam.sh timer' in a second terminal for a dedicated timer view.${NC}"
  echo

  run_lab_setup "$QDIR" "$QID"
  show_question "$QDIR" "$QTITLE" 1
  end_command_output
}

cmd_timer() {
  load_state
  run_foreground_timer "$STATE_DIR"
}

cmd_pause() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
  if [[ "${EXAM_FINISHED:-0}" -eq 1 ]]; then
    echo "Exam already finished."
    exit 1
  fi
  if [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 ]]; then
    echo "Timer is already paused for lab setup."
    exit 1
  fi
  if [[ "${BREAK_IN_PROGRESS:-0}" -eq 1 ]]; then
    echo "Timer is already paused for a break."
    show_timer
    exit 0
  fi

  timer_pause_for_break
  save_state
  begin_command_output
  echo -e "${YELLOW}⏸  Exam timer paused for break.${NC}"
  show_timer
  echo "Resume with: exercises/cka-exam.sh resume"
  end_command_output
}

cmd_resume() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
  if [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 ]]; then
    echo "Timer is paused for lab setup and will resume automatically when setup completes."
    exit 1
  fi
  if [[ "${BREAK_IN_PROGRESS:-0}" -ne 1 ]]; then
    echo "Timer is not paused. Use 'pause' to take a break."
    show_timer
    exit 0
  fi

  timer_resume_after_break
  save_state
  begin_command_output
  echo -e "${GREEN}▶  Exam timer resumed.${NC}"
  show_timer
  end_command_output
}

cmd_status() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi

  begin_command_output
  banner
  parse_question "${CURRENT_INDEX:-0}"
  local qnum=$((CURRENT_INDEX + 1))
  echo -e "${BOLD}Current question:${NC} ${qnum}/${TOTAL_QUESTIONS} — ${QTITLE} (${QID})"
  show_timer
  if [[ -f "$STATE_DIR/timer.display" ]]; then
    echo -e "${BOLD}Live display:${NC} $(cat "$STATE_DIR/timer.display")"
  fi
  show_score_summary "$SCORES_FILE"
  echo
  if [[ "${EXAM_FINISHED:-0}" -eq 1 ]]; then
    echo "Exam finished."
  fi
  end_command_output
}

cmd_check() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
  if time_expired; then
    begin_command_output
    echo -e "${RED}Time has expired.${NC}"
    end_command_output
    cmd_finish
    exit 0
  fi

  begin_command_output
  parse_question "${CURRENT_INDEX:-0}"
  echo -e "${BOLD}Checking question ${QID}...${NC}"
  echo
  bash "$EXERCISES_DIR/validate.sh" "$QID" --record "$SCORES_FILE" || true
  echo
  show_score_summary "$SCORES_FILE"
  end_command_output
}

cmd_next() {
  load_state
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    exit 1
  fi
  if time_expired; then
    begin_command_output
    echo -e "${RED}Time has expired.${NC}"
    end_command_output
    cmd_finish
    exit 0
  fi

  begin_command_output
  local next_index=$((CURRENT_INDEX + 1))
  if [[ $next_index -ge $TOTAL_QUESTIONS ]]; then
    echo "All questions completed!"
    end_command_output
    cmd_finish
    return
  fi

  CURRENT_INDEX=$next_index
  save_state

  parse_question "$CURRENT_INDEX"
  local qnum=$((CURRENT_INDEX + 1))

  run_lab_setup "$QDIR" "$QID"
  show_question "$QDIR" "$QTITLE" "$qnum"
  end_command_output
}

cmd_prev() {
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

  if [[ "${CURRENT_INDEX:-0}" -le 0 ]]; then
    begin_command_output
    echo "Already at the first question."
    end_command_output
    exit 1
  fi

  CURRENT_INDEX=$((CURRENT_INDEX - 1))
  save_state

  parse_question "$CURRENT_INDEX"
  local qnum=$((CURRENT_INDEX + 1))

  begin_command_output
  echo -e "${YELLOW}Returning to previous question — lab environment will be reset.${NC}"
  run_lab_setup "$QDIR" "$QID"
  show_question "$QDIR" "$QTITLE" "$qnum"
  end_command_output
}

cmd_skip() {
  begin_command_output
  echo -e "${YELLOW}Skipping check for current question.${NC}"
  end_command_output
  cmd_next
}

cmd_finish() {
  load_state
  stop_timer_daemon
  EXAM_FINISHED=1
  EXAM_ACTIVE=0
  save_state

  banner
  echo -e "${BOLD}══════ FINAL EXAM RESULTS ══════${NC}"
  echo

  local end_time
  end_time=$(date +%s)
  if [[ -n "${EXAM_START:-}" && "$EXAM_START" -gt 0 ]]; then
    local paused=${PAUSED_SECONDS:-0}
    local elapsed=$((end_time - EXAM_START - paused))
    echo -e "${BOLD}Time used:${NC} $(format_time "$elapsed") / $(format_time $EXAM_DURATION)"
    echo -e "${BOLD}Setup time excluded:${NC} $(format_time "$paused")"
  fi

  echo
  show_score_summary "$SCORES_FILE"
  echo

  show_final_breakdown "$SCORES_FILE"
  echo
  echo -e "${GREEN}Exam complete.${NC} State saved in $STATE_DIR"
}

cmd_reset() {
  stop_timer_daemon
  rm -rf "$STATE_DIR"
  echo "Exam state cleared. Run 'exercises/cka-exam.sh start' to begin a new exam."
}

# Main
COMMAND="${1:-}"
case "$COMMAND" in
  start)  cmd_start ;;
  timer)  cmd_timer ;;
  pause)  cmd_pause ;;
  resume) cmd_resume ;;
  status) cmd_status ;;
  check)  cmd_check ;;
  next)   cmd_next ;;
  prev)   cmd_prev ;;
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
