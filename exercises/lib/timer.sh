#!/bin/bash
# Live exam timer helpers.
# Timer updates use save/restore cursor on line 1 only — never reposition exam output.

TIMER_BAR_LINE=1

timer_tty() {
  [[ -t 1 || -t 2 ]]
}

timer_format_bar() {
  local formatted="$1"
  local pause_label="$2"
  local qinfo="${3:-}"

  local bar="⏱  Time remaining: ${formatted}"
  if [[ -n "$pause_label" ]]; then
    bar+="  (${pause_label})"
  fi
  if [[ -n "$qinfo" ]]; then
    bar+="  |  ${qinfo}"
  fi
  echo "$bar"
}

timer_init_display() {
  if ! timer_tty; then
    return 0
  fi
  # Draw initial bar without moving the cursor used for normal command output.
  timer_draw_bar "⏱  Exam timer starting..."
}

timer_begin_content_area() {
  # Intentionally empty — do not jump cursor to a fixed row; that overwrites prior output.
  :
}

timer_draw_bar() {
  local text="$1"
  if ! timer_tty; then
    return 0
  fi
  # Save cursor, update line 1 on stderr, restore cursor so output continues below.
  printf '\033[s\033[%d;0H\033[2K%s\033[u' "$TIMER_BAR_LINE" "$text" >&2
}

timer_clear_bar() {
  if ! timer_tty; then
    return 0
  fi
  printf '\033[s\033[%d;0H\033[2K\033[u' "$TIMER_BAR_LINE" >&2
}

timer_clear_line() {
  timer_clear_bar
}

timer_newline() {
  :
}

timer_pause_label() {
  if [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 ]]; then
    echo "paused — lab setup in progress"
  elif [[ "${BREAK_IN_PROGRESS:-0}" -eq 1 ]]; then
    echo "paused — break"
  else
    echo ""
  fi
}

timer_is_paused() {
  [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 || "${BREAK_IN_PROGRESS:-0}" -eq 1 ]]
}

remaining_seconds() {
  if [[ -z "${EXAM_START:-}" || "$EXAM_START" -eq 0 ]]; then
    echo "${EXAM_DURATION:-7200}"
    return
  fi

  local now elapsed paused remaining
  now=$(date +%s)
  paused=${PAUSED_SECONDS:-0}

  if [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 && -n "${SETUP_PAUSE_START:-}" && "$SETUP_PAUSE_START" -gt 0 ]]; then
    paused=$((paused + now - SETUP_PAUSE_START))
  elif [[ "${BREAK_IN_PROGRESS:-0}" -eq 1 && -n "${BREAK_PAUSE_START:-}" && "$BREAK_PAUSE_START" -gt 0 ]]; then
    paused=$((paused + now - BREAK_PAUSE_START))
  fi

  elapsed=$((now - EXAM_START - paused))
  remaining=$((EXAM_DURATION - elapsed))
  [[ $remaining -lt 0 ]] && remaining=0
  echo "$remaining"
}

format_time() {
  local secs=$1
  printf '%02d:%02d:%02d' $((secs / 3600)) $(((secs % 3600) / 60)) $((secs % 60))
}

time_expired() {
  [[ $(remaining_seconds) -eq 0 ]] && ! timer_is_paused
}

timer_question_label() {
  local idx="${CURRENT_INDEX:-0}"
  local total="${TOTAL_QUESTIONS:-0}"
  if [[ "$total" -gt 0 ]]; then
    echo "Q$((idx + 1))/${total}"
  fi
}

timer_refresh_bar() {
  local state_dir="${STATE_DIR:-}"
  [[ -z "$state_dir" || ! -f "${state_dir}/state.env" ]] && return 0

  # shellcheck disable=SC1090
  source "${state_dir}/state.env"

  local remaining formatted pause_label qinfo bar
  remaining=$(remaining_seconds)
  formatted=$(format_time "$remaining")
  pause_label=$(timer_pause_label)
  qinfo=$(timer_question_label)
  bar=$(timer_format_bar "$formatted" "$pause_label" "$qinfo")

  echo "$remaining" > "${state_dir}/timer.remaining"
  echo "$formatted" > "${state_dir}/timer.display"
  timer_draw_bar "$bar"
}

timer_pause_for_setup() {
  SETUP_IN_PROGRESS=1
  SETUP_PAUSE_START=$(date +%s)
}

timer_resume_after_setup() {
  local setup_end
  setup_end=$(date +%s)
  if [[ -n "${SETUP_PAUSE_START:-}" && "$SETUP_PAUSE_START" -gt 0 ]]; then
    PAUSED_SECONDS=$(( ${PAUSED_SECONDS:-0} + setup_end - SETUP_PAUSE_START ))
  fi
  SETUP_IN_PROGRESS=0
  SETUP_PAUSE_START=0
}

timer_pause_for_break() {
  BREAK_IN_PROGRESS=1
  BREAK_PAUSE_START=$(date +%s)
}

timer_resume_after_break() {
  local break_end
  break_end=$(date +%s)
  if [[ -n "${BREAK_PAUSE_START:-}" && "$BREAK_PAUSE_START" -gt 0 ]]; then
    PAUSED_SECONDS=$(( ${PAUSED_SECONDS:-0} + break_end - BREAK_PAUSE_START ))
  fi
  BREAK_IN_PROGRESS=0
  BREAK_PAUSE_START=0
}

stop_timer_daemon() {
  if [[ -f "${STATE_DIR}/timer.pid" ]]; then
    local pid
    pid=$(cat "${STATE_DIR}/timer.pid" 2>/dev/null || true)
    if [[ -n "$pid" ]]; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
    rm -f "${STATE_DIR}/timer.pid"
  fi
  timer_clear_bar
}

start_timer_daemon() {
  local state_dir="$1"
  local exercises_dir="$2"

  stop_timer_daemon
  timer_init_display

  (
    # shellcheck disable=SC1090
    source "$exercises_dir/lib/timer.sh"
    export STATE_DIR="$state_dir"

    while [[ -f "${state_dir}/state.env" ]]; do
      # shellcheck disable=SC1090
      source "${state_dir}/state.env"
      export CURRENT_INDEX

      if [[ "${EXAM_ACTIVE:-0}" -ne 1 || "${EXAM_FINISHED:-0}" -eq 1 ]]; then
        break
      fi

      timer_refresh_bar
      sleep 1
    done

    timer_clear_bar
  ) &

  echo $! > "${state_dir}/timer.pid"
}

run_foreground_timer() {
  local state_dir="$1"

  if [[ ! -f "${state_dir}/state.env" ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    return 1
  fi

  # shellcheck disable=SC1090
  source "${state_dir}/state.env"
  if [[ "${EXAM_ACTIVE:-0}" -ne 1 ]]; then
    echo "No active exam. Run: exercises/cka-exam.sh start"
    return 1
  fi

  export STATE_DIR="$state_dir"
  echo "Live exam timer (Ctrl+C to stop this view; exam continues)"
  trap 'printf "\n"; exit 0' INT TERM

  while [[ -f "${state_dir}/state.env" ]]; do
    # shellcheck disable=SC1090
    source "${state_dir}/state.env"
    export CURRENT_INDEX
    [[ "${EXAM_ACTIVE:-0}" -ne 1 || "${EXAM_FINISHED:-0}" -eq 1 ]] && break

    local remaining formatted pause_label qinfo bar
    remaining=$(remaining_seconds)
    formatted=$(format_time "$remaining")
    pause_label=$(timer_pause_label)
    qinfo=$(timer_question_label)
    bar=$(timer_format_bar "$formatted" "$pause_label" "$qinfo")

    printf '\r\033[2K%s' "$bar"
    sleep 1
  done

  printf '\r\033[2K\n'
}
