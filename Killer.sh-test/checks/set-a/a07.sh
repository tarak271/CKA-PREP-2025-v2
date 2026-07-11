#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


if ! kubectl top nodes &>/dev/null 2>&1; then
  fail_task "metrics" "metrics-server available" "Run: ensure_metrics_server (re-run lab setup) or install metrics-server"
else
  pass_task "metrics" "metrics-server available"
fi
DIR=$(course_path 7)
if [[ -x "$DIR/node.sh" ]] && "$DIR/node.sh" 2>/dev/null | grep -qiE 'cpu|memory|name'; then
  pass_task "node-sh" "node.sh shows node resource usage"
else
  fail_task "node-sh" "node.sh shows node resource usage" "echo 'kubectl top node' > $DIR/node.sh && chmod +x $DIR/node.sh"
fi
if [[ -x "$DIR/pod.sh" ]] && "$DIR/pod.sh" 2>/dev/null | grep -qiE 'cpu|memory|pod'; then
  pass_task "pod-sh" "pod.sh shows pod resource usage"
else
  fail_task "pod-sh" "pod.sh shows pod resource usage" "echo 'kubectl top pod --containers=true' > $DIR/pod.sh && chmod +x $DIR/pod.sh"
fi


print_summary "a07"
