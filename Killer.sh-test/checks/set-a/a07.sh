#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results

METRICS_OK=0
if kubectl top nodes &>/dev/null 2>&1; then
  pass_task "metrics" "metrics-server available"
  METRICS_OK=1
else
  fail_task "metrics" "metrics-server available" "Run: ensure_metrics_server (re-run lab setup) or install metrics-server"
fi
DIR=$(course_path 7)

# node.sh — verify correct kubectl top node command in the script
if [[ -f "$DIR/node.sh" ]] && grep -qE 'kubectl[[:space:]]+top[[:space:]]+node' "$DIR/node.sh"; then
  if [[ $METRICS_OK -eq 1 ]]; then
    pass_task "node-sh" "node.sh shows node resource usage"
  elif bash "$DIR/node.sh" &>/dev/null; then
    pass_task "node-sh" "node.sh shows node resource usage"
  else
    fail_task "node-sh" "node.sh shows node resource usage" "Fix metrics-server, then ensure node.sh contains: kubectl top node"
  fi
else
  fail_task "node-sh" "node.sh shows node resource usage" "echo 'kubectl top node' > $DIR/node.sh && chmod +x $DIR/node.sh"
fi

# pod.sh — verify kubectl top pod with per-container usage
if [[ -f "$DIR/pod.sh" ]] && grep -qE 'kubectl[[:space:]]+top[[:space:]]+pod' "$DIR/pod.sh" && grep -qE 'containers' "$DIR/pod.sh"; then
  if [[ $METRICS_OK -eq 1 ]]; then
    pass_task "pod-sh" "pod.sh shows pod resource usage"
  elif bash "$DIR/pod.sh" &>/dev/null; then
    pass_task "pod-sh" "pod.sh shows pod resource usage"
  else
    fail_task "pod-sh" "pod.sh shows pod resource usage" "Fix metrics-server, then ensure pod.sh contains: kubectl top pod --containers=true"
  fi
else
  fail_task "pod-sh" "pod.sh shows pod resource usage" "echo 'kubectl top pod --containers=true' > $DIR/pod.sh && chmod +x $DIR/pod.sh"
fi

print_summary "a07"
