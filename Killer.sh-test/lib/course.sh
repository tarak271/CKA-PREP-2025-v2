#!/bin/bash
# Helpers for /opt/course paths used by Killer.sh-style questions.

KILLER_COURSE_DIR="${KILLER_COURSE_DIR:-/opt/course}"

ensure_course_dir() {
  local num="$1"
  local dir="${KILLER_COURSE_DIR}/${num}"
  if [[ ! -d "$dir" ]]; then
    if [[ "$(id -u)" -eq 0 ]]; then
      mkdir -p "$dir"
    else
      sudo mkdir -p "$dir"
      sudo chown "$(id -u):$(id -g)" "$dir" 2>/dev/null || true
    fi
  fi
  echo "$dir"
}

course_path() {
  echo "${KILLER_COURSE_DIR}/$1"
}

reset_course_outputs() {
  local num="$1"
  shift
  local dir
  dir=$(ensure_course_dir "$num")
  for f in "$@"; do
    rm -f "${dir}/${f}"
  done
}
