#!/bin/bash
set -euo pipefail

KILLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$KILLER_DIR/.." && pwd)"
EXERCISES_DIR="$REPO_ROOT/exercises"

source "$KILLER_DIR/lib/common.sh"
source "$EXERCISES_DIR/lib/timer.sh"
source "$KILLER_DIR/lib/course.sh"

EXAM_DURATION=7200  # 2 hours
STATE_DIR="${HOME}/.killer-exam"
STATE_FILE="$STATE_DIR/state.env"
SCORES_FILE="$STATE_DIR/scores.tsv"

EXAM_SET=""
QUESTION_ORDER=()
TOTAL_QUESTIONS=0
TOTAL_MARKS=0

load_set_config() {
  local set="${EXAM_SET:-}"
  if [[ -z "$set" ]]; then
    load_state
    set="${EXAM_SET:-}"
  fi
  if [[ -z "$set" ]]; then
    echo "Exam set not selected. Use: killer-exam.sh start --set A|B" >&2
    exit 1
  fi
  set=$(echo "$set" | tr '[:upper:]' '[:lower:]')
  if [[ "$set" != "a" && "$set" != "b" ]]; then
    echo "Invalid set: $set (use A or B)" >&2
    exit 1
  fi
  EXAM_SET="$set"

  # shellcheck source=/dev/null
  source "$KILLER_DIR/lib/questions-set-${EXAM_SET}.sh"
  # shellcheck source=/dev/null
  source "$KILLER_DIR/lib/cleanup-set-${EXAM_SET}.sh"

  local config="$KILLER_DIR/exam-config-set-${EXAM_SET}.yaml"
  QUESTION_ORDER=()
  TOTAL_MARKS=0
  local qid="" dir="" marks=""
  while IFS= read -r line; do
    if [[ "$line" =~ id:[[:space:]]*(a[0-9]+|b[0-9]+) ]]; then
      qid="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ marks:[[:space:]]*([0-9]+) ]]; then
      marks="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ dir:[[:space:]]*(Question-[^[:space:]]+) ]]; then
      dir="${BASH_REMATCH[1]}"
      if [[ -n "$qid" && -n "$dir" && -n "$marks" ]]; then
        local title="${dir#Question-*-}"
        title="${title//-/ }"
        QUESTION_ORDER+=("${qid}:${dir}:${title}:${marks}")
        TOTAL_MARKS=$((TOTAL_MARKS + marks))
        qid=""; dir=""; marks=""
      fi
    fi
  done < "$config"
  TOTAL_QUESTIONS=${#QUESTION_ORDER[@]}
}

banner() {
  local set_label
  set_label=$(echo "${EXAM_SET:-?}" | tr '[:lower:]' '[:upper:]')
  echo -e "${CYAN}${BOLD}"
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║     Killer.sh CKA Practice Exam — Set ${set_label} — 2 Hours          ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

usage() {
  banner
  cat <<EOF
Usage: Killer.sh-test/killer-exam.sh <command> [--set A|B]

Commands:
  start     Begin the 2-hour exam (cleanup + lab setup for question 1)
  timer     Live countdown in this terminal (updates every second)
  pause     Pause the exam timer for a break
  resume    Resume the exam timer after a break
  status    Show remaining time, current question, and score
  check     Validate the current question (1 mark per sub-task)
  next      Move to the next question (cleanup + lab setup)
  prev      Go back to the previous question (cleanup + lab setup)
  skip      Skip to next question without checking
  finish    End exam early and show final score
  reset     Clear exam state (optionally: reset --set A|B)

Options:
  --set A|B   Select question set (required for start)

Environment:
  KILLER_COURSE_DIR  Base path for course files (default: /opt/course)

During the exam:
  1. Live timer runs continuously and stays pinned to the top line.
  2. Timer pauses during cleanup and lab setup (setup time excluded).
  3. Use pause/resume for breaks (break time excluded).
  4. Run: Killer.sh-test/killer-exam.sh check
  5. Run: Killer.sh-test/killer-exam.sh next  or  prev

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
EXAM_SET=${EXAM_SET:-}
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
TOTAL_MARKS=${TOTAL_MARKS:-0}
EOF
}

check_prerequisites() {
  local errors=0
  echo "Checking prerequisites..."

  if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "  ${YELLOW}⚠${NC} Not running on Linux (designed for Ubuntu/Killercoda)"
  else
    echo -e "  ${GREEN}✓${NC} Linux detected"
  fi

  command -v kubectl &>/dev/null && echo -e "  ${GREEN}✓${NC} kubectl found" || { echo -e "  ${RED}✗${NC} kubectl not found"; errors=$((errors + 1)); }
  command -v python3 &>/dev/null && echo -e "  ${GREEN}✓${NC} python3 found" || { echo -e "  ${RED}✗${NC} python3 required"; errors=$((errors + 1)); }

  kubectl cluster-info &>/dev/null 2>&1 || kubectl get nodes &>/dev/null 2>&1 && \
    echo -e "  ${GREEN}✓${NC} Kubernetes cluster reachable" || \
    echo -e "  ${YELLOW}⚠${NC} Cluster not reachable (some questions may still work)"

  [[ $errors -eq 0 ]]
}

parse_question() {
  local idx=$1
  local entry="${QUESTION_ORDER[$idx]}"
  IFS=':' read -r QID QDIR QTITLE QMARKS <<< "$entry"
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
    echo -e "${RED}Time is up! Submit with: Killer.sh-test/killer-exam.sh finish${NC}"
  fi
}

ensure_exam_active() {
  load_state
  load_set_config
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: Killer.sh-test/killer-exam.sh start --set A|B"
    exit 1
  fi
}

begin_command_output() { timer_begin_content_area; }
end_command_output() { export STATE_DIR; timer_refresh_bar; }

show_score_summary() {
  local earned=0
  if [[ -f "$SCORES_FILE" ]]; then
    while IFS=$'\t' read -r qid task_id status mark; do
      earned=$((earned + mark))
    done < "$SCORES_FILE"
  fi
  echo -e "${BOLD}Score:${NC} ${earned}/${TOTAL_MARKS} marks"
  local pct=0
  [[ $TOTAL_MARKS -gt 0 ]] && pct=$((earned * 100 / TOTAL_MARKS))
  echo -e "${BOLD}Percentage:${NC} ${pct}%"
}

run_lab_setup() {
  local qdir="$1"
  local qid="$2"
  local setup="$KILLER_DIR/set-${EXAM_SET}/$qdir/LabSetUp.bash"
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
  echo -e "${CYAN}==> Running lab setup for Set-${EXAM_SET^^} ${qdir}${NC}"
  echo -e "${YELLOW}⏸  Exam timer paused during setup${NC}"

  set +e
  "$setup"
  local rc=$?
  set -e

  load_state
  timer_resume_after_setup
  save_state

  echo -e "${GREEN}▶  Exam timer resumed${NC}"
  [[ $rc -ne 0 ]] && echo -e "${YELLOW}Lab setup exited with code $rc (you may still attempt the question)${NC}"
  end_command_output
}

show_question() {
  local qdir="$1" qtitle="$2" qnum="$3"
  local questions_file="$KILLER_DIR/set-${EXAM_SET}/$qdir/Questions.bash"
  echo
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Set ${EXAM_SET^^} — Question ${qnum}/${TOTAL_QUESTIONS}: ${qtitle}${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  show_timer
  echo
  if [[ -f "$questions_file" ]]; then
    bash "$questions_file"
  else
    echo "Question file not found: $questions_file"
  fi
  echo
  echo -e "${YELLOW}Check answer:${NC}   Killer.sh-test/killer-exam.sh check"
  echo -e "${YELLOW}Next question:${NC}  Killer.sh-test/killer-exam.sh next"
  echo -e "${YELLOW}Previous:${NC}       Killer.sh-test/killer-exam.sh prev"
}

cmd_start() {
  if [[ -z "${EXAM_SET:-}" ]]; then
    echo "Select a set: Killer.sh-test/killer-exam.sh start --set A|B" >&2
    exit 1
  fi
  load_set_config
  banner
  if ! check_prerequisites; then
    echo -e "${RED}Prerequisites not met.${NC}"
    exit 1
  fi

  load_state
  if [[ "${EXAM_ACTIVE:-0}" -eq 1 && "${EXAM_FINISHED:-0}" -eq 0 ]]; then
    echo "Exam already in progress (Set ${EXAM_SET^^}). Use status or reset."
    exit 1
  fi

  stop_timer_daemon

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
  timer_begin_content_area

  parse_question 0
  echo -e "${GREEN}Exam started!${NC} Set ${EXAM_SET^^} | $(format_time $EXAM_DURATION) | ${TOTAL_QUESTIONS} questions | ${TOTAL_MARKS} marks"
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
  [[ "${EXAM_ACTIVE:-0}" -ne 1 ]] && { echo "No active exam."; exit 1; }
  [[ "${BREAK_IN_PROGRESS:-0}" -eq 1 ]] && { show_timer; exit 0; }
  timer_pause_for_break
  save_state
  begin_command_output
  echo -e "${YELLOW}⏸  Timer paused.${NC}"
  show_timer
  end_command_output
}

cmd_resume() {
  load_state
  [[ "${BREAK_IN_PROGRESS:-0}" -ne 1 ]] && { show_timer; exit 0; }
  timer_resume_after_break
  save_state
  begin_command_output
  echo -e "${GREEN}▶  Timer resumed.${NC}"
  show_timer
  end_command_output
}

cmd_status() {
  load_state
  load_set_config
  [[ "${EXAM_ACTIVE:-0}" -ne 1 ]] && { echo "No active exam."; exit 1; }
  begin_command_output
  banner
  parse_question "${CURRENT_INDEX:-0}"
  echo -e "${BOLD}Set:${NC} ${EXAM_SET^^} | ${BOLD}Question:${NC} $((CURRENT_INDEX + 1))/${TOTAL_QUESTIONS} — ${QTITLE} (${QID})"
  show_timer
  show_score_summary
  end_command_output
}

cmd_check() {
  ensure_exam_active
  if time_expired; then
    cmd_finish
    exit 0
  fi
  begin_command_output
  parse_question "${CURRENT_INDEX:-0}"
  echo -e "${BOLD}Checking ${QID}...${NC}"
  echo
  bash "$KILLER_DIR/validate.sh" "$QID" --record "$SCORES_FILE" || true
  echo
  show_score_summary
  end_command_output
}

cmd_next() {
  ensure_exam_active
  if time_expired; then cmd_finish; exit 0; fi
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
  run_lab_setup "$QDIR" "$QID"
  show_question "$QDIR" "$QTITLE" "$((CURRENT_INDEX + 1))"
  end_command_output
}

cmd_prev() {
  ensure_exam_active
  if [[ "${CURRENT_INDEX:-0}" -le 0 ]]; then
    begin_command_output
    echo "Already at the first question."
    end_command_output
    exit 1
  fi
  CURRENT_INDEX=$((CURRENT_INDEX - 1))
  save_state
  parse_question "$CURRENT_INDEX"
  begin_command_output
  echo -e "${YELLOW}Returning to previous question — environment will be reset.${NC}"
  run_lab_setup "$QDIR" "$QID"
  show_question "$QDIR" "$QTITLE" "$((CURRENT_INDEX + 1))"
  end_command_output
}

cmd_skip() {
  begin_command_output
  echo -e "${YELLOW}Skipping check.${NC}"
  end_command_output
  cmd_next
}

cmd_finish() {
  load_state
  load_set_config
  stop_timer_daemon
  EXAM_FINISHED=1
  EXAM_ACTIVE=0
  save_state

  banner
  echo -e "${BOLD}══════ FINAL RESULTS — Set ${EXAM_SET^^} ══════${NC}"
  echo
  show_score_summary
  echo
  if [[ -f "$SCORES_FILE" ]]; then
    echo -e "${BOLD}Breakdown:${NC}"
    local current_qid="" q_earned=0 q_total=0
    while IFS=$'\t' read -r qid task_id status mark; do
      if [[ -n "$current_qid" && "$qid" != "$current_qid" ]]; then
        printf "  %-6s %2d marks\n" "$current_qid" "$q_earned"
        q_earned=0
      fi
      current_qid="$qid"
      q_earned=$((q_earned + mark))
    done < "$SCORES_FILE"
    [[ -n "$current_qid" ]] && printf "  %-6s %2d marks\n" "$current_qid" "$q_earned"
  fi
  echo
  echo -e "${GREEN}Exam complete.${NC} State: $STATE_DIR"
}

cmd_reset() {
  stop_timer_daemon
  rm -rf "$STATE_DIR"
  echo "Killer exam state cleared."
}

# Parse global options
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --set)
      EXAM_SET="$2"
      shift 2
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

COMMAND="${ARGS[0]:-}"
case "$COMMAND" in
  start)  cmd_start ;;
  timer)  load_state; cmd_timer ;;
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
