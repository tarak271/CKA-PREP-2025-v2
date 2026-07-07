#!/bin/bash
# Live exam timer helpers.

timer_clear_line() {
  if [[ -t 2 ]]; then
    printf '\r\033[2K' >&2
  fi
}

timer_newline() {
  if [[ -t 2 ]]; then
    printf '\n' >&2
  fi
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
  [[ $(remaining_seconds) -eq 0 ]]
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
  timer_clear_line
}

start_timer_daemon() {
  local state_dir="$1"
  local exercises_dir="$2"

  stop_timer_daemon

  (
    # shellcheck disable=SC1090
    source "$exercises_dir/lib/timer.sh"

    while [[ -f "${state_dir}/state.env" ]]; do
      # shellcheck disable=SC1090
      source "${state_dir}/state.env"

      if [[ "${EXAM_ACTIVE:-0}" -ne 1 || "${EXAM_FINISHED:-0}" -eq 1 ]]; then
        break
      fi

      local remaining formatted
      remaining=$(remaining_seconds)
      formatted=$(format_time "$remaining")

      echo "$remaining" > "${state_dir}/timer.remaining"
      echo "$formatted" > "${state_dir}/timer.display"

      if [[ -t 2 ]]; then
        if [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 ]]; then
          printf '\r\033[2K⏱  Time remaining: %s  (paused — lab setup in progress)' "$formatted" >&2
        else
          printf '\r\033[2K⏱  Time remaining: %s' "$formatted" >&2
        fi
      fi

      sleep 1
    done

    timer_clear_line
    timer_newline
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

  echo "Live exam timer (Ctrl+C to stop display; exam continues)"
  trap 'timer_clear_line; timer_newline; exit 0' INT TERM

  while [[ -f "${state_dir}/state.env" ]]; do
    # shellcheck disable=SC1090
    source "${state_dir}/state.env"
    [[ "${EXAM_ACTIVE:-0}" -ne 1 || "${EXAM_FINISHED:-0}" -eq 1 ]] && break

    local remaining formatted
    remaining=$(remaining_seconds)
    formatted=$(format_time "$remaining")

    if [[ "${SETUP_IN_PROGRESS:-0}" -eq 1 ]]; then
      printf '\r\033[2K⏱  Time remaining: %s  (paused — lab setup in progress)' "$formatted"
    else
      printf '\r\033[2K⏱  Time remaining: %s' "$formatted"
    fi

    sleep 1
  done

  printf '\r\033[2K\n'
}
