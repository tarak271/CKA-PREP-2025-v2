#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -f "$(course_path 16)/resources.txt" ]] && pass_task "resources" "Namespaced API resources listed" || fail_task "resources" "Namespaced API resources listed"
crowded="$(course_path 16)/crowded-namespace.txt"
if [[ -f "$crowded" ]] && grep -qi 'project-miami' "$crowded" && grep -q '300' "$crowded"; then
  pass_task "crowded" "project-miami with 300 roles identified"
else
  fail_task "crowded" "project-miami with 300 roles identified" "Expected: project-miami with 300 roles"
fi


print_summary "b16"
