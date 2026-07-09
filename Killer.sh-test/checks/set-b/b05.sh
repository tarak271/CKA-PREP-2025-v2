#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


DIR=$(course_path 5)
if [[ -x "$DIR/find_pods.sh" ]]; then
  out=$("$DIR/find_pods.sh" 2>/dev/null | head -5)
  [[ -n "$out" ]] && pass_task "age-sort" "find_pods.sh lists pods sorted by age" || fail_task "age-sort" "find_pods.sh lists pods sorted by age"
else
  fail_task "age-sort" "find_pods.sh created and executable"
fi
if [[ -x "$DIR/find_pods_uid.sh" ]]; then
  out=$("$DIR/find_pods_uid.sh" 2>/dev/null | head -5)
  [[ -n "$out" ]] && pass_task "uid-sort" "find_pods_uid.sh lists pods sorted by uid" || fail_task "uid-sort" "find_pods_uid.sh lists pods sorted by uid"
else
  fail_task "uid-sort" "find_pods_uid.sh created and executable"
fi


print_summary "b05"
