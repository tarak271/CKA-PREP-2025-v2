#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


DIR=$(course_path 7)
if [[ -x "$DIR/node.sh" ]] && "$DIR/node.sh" 2>/dev/null | grep -qiE 'cpu|memory|name'; then
  pass_task "node-sh" "node.sh shows node resource usage"
else
  fail_task "node-sh" "node.sh shows node resource usage"
fi
if [[ -x "$DIR/pod.sh" ]] && "$DIR/pod.sh" 2>/dev/null | grep -qiE 'cpu|memory|pod'; then
  pass_task "pod-sh" "pod.sh shows pod resource usage"
else
  fail_task "pod-sh" "pod.sh shows pod resource usage"
fi


print_summary "a07"
