#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


FILE="$(course_path 9)/result.json"
if [[ -f "$FILE" ]] && python3 -c "import json; json.load(open('$FILE'))" 2>/dev/null; then
  pass_task "json" "result.json contains valid JSON from API call"
else
  fail_task "json" "result.json contains valid JSON from API call"
fi


print_summary "a09"
